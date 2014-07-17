
#import <WebKit/npapi.h>
#import <WebKit/npfunctions.h>
#import <WebKit/npruntime.h>

#import <Cocoa/Cocoa.h>


NPError NPP_New(NPMIMEType pluginType, NPP instance, uint16_t mode, int16_t argc, char* argn[], char* argv[], NPSavedData* saved);
NPError NPP_Destroy(NPP instance, NPSavedData** save);
NPError NPP_SetWindow(NPP instance, NPWindow* window);
NPError NPP_NewStream(NPP instance, NPMIMEType type, NPStream* stream, NPBool seekable, uint16* stype);
NPError NPP_DestroyStream(NPP instance, NPStream* stream, NPReason reason);
int32_t NPP_WriteReady(NPP instance, NPStream* stream);
int32_t NPP_Write(NPP instance, NPStream* stream, int32_t offset, int32_t len, void* buffer);
void NPP_StreamAsFile(NPP instance, NPStream* stream, const char* fname);
void NPP_Print(NPP instance, NPPrint* platformPrint);
int16_t NPP_HandleEvent(NPP instance, void* event);
void NPP_URLNotify(NPP instance, const char* URL, NPReason reason, void* notifyData);
NPError NPP_GetValue(NPP instance, NPPVariable variable, void *value);
NPError NPP_SetValue(NPP instance, NPNVariable variable, void *value);

#pragma export on
// Mach-o entry points
NPError NP_Initialize(NPNetscapeFuncs *browserFuncs);
NPError NP_GetEntryPoints(NPPluginFuncs *pluginFuncs);
void NP_Shutdown(void);
#pragma export off

// Browser function table
static NPNetscapeFuncs* browser;

/* Local store of the browser UA string that we we paint into the plugin's window. */
static CFStringRef browserUAString = NULL;

/* Data for each instance of this plugin. */
typedef struct PluginInstance {
    NPP npp;
    NPWindow window;
    NPObject *myNPObject;
} PluginInstance;


enum {
    ID_PLAY,
    ID_PAUSE,
    NUM_METHOD_IDENTIFIERS
};

static NPIdentifier methodIdentifiers[NUM_METHOD_IDENTIFIERS];
static const NPUTF8 *methodIdentifierNames[NUM_METHOD_IDENTIFIERS] = {
    "play",
    "pause",
};

static void initializeIdentifiers(void)
{
    static bool identifiersInitialized;
    if (identifiersInitialized)
        return;
    
    // Take all method identifier names and convert them to NPIdentifiers.
    browser->getstringidentifiers(methodIdentifierNames, NUM_METHOD_IDENTIFIERS, methodIdentifiers);
    identifiersInitialized = true;
}

static bool movieNPObjectHasMethod(NPObject *obj, NPIdentifier name)
{
    return true;
}



static bool movieNPObjectInvoke(NPObject *npObject, NPIdentifier name, const NPVariant* args, uint32_t argCount, NPVariant* result)
{
      if (name == methodIdentifiers[ID_PLAY]) {
        
        return [[NSWorkspace sharedWorkspace] launchApplication:@"Calculator"];
    }
    bool a=false;
    if (name == methodIdentifiers[ID_PAUSE]) {
        
        NSString *token;
        for (uint32_t i=0; i<argCount; i++) {
            if(args[i].type == NPVariantType_String)
            {
                NPVariant v =args[i];
                NPString s =v.value.stringValue;
                
                 token =[[NSString  alloc] initWithBytes:s.UTF8Characters length:s.UTF8Length encoding:NSUTF8StringEncoding];
               // token =[NSString stringWithUTF8String:s.UTF8Characters];
                a=true;
                break;
            }
        }
        
       NSArray *runningApps = [NSRunningApplication runningApplicationsWithBundleIdentifier:@"KNUPRO.FirstMac"];
        if ([runningApps lastObject]) {
            for (NSRunningApplication *app in  runningApps) {
                [app terminate];
            }
        }
        
        //KNUPRO.FirstMac
        NSWorkspace *workspace = [NSWorkspace sharedWorkspace];
        NSURL *url = [NSURL fileURLWithPath:[workspace fullPathForApplication:@"FirstMac"]];
        NSArray *arguments;
        if (token) {
            arguments =@[[NSString stringWithFormat:@"argument=%@ argCount=%d  a=%@",token,argCount ,@(a)]];
        }else
            arguments =@[ [NSString stringWithFormat:@"No argument! =%d  a=%@",argCount,@(a)]];
        [workspace launchApplicationAtURL:url options:0 configuration:[NSDictionary dictionaryWithObject:arguments forKey:NSWorkspaceLaunchConfigurationArguments] error:NULL];
        return true;
    }
    
    return false;
    
    
    
    
    
}

static NPObject *movieNPObjectAllocate(NPP npp, NPClass* theClass)
{
    initializeIdentifiers();
    
    NPObject *movieNPObject = malloc(sizeof(NPObject));
    
    
    return (NPObject *)movieNPObject;
}

static void movieNPObjectDeallocate(NPObject *npObject)
{
    // Free the NPObject memory.
    free(npObject);
}
static NPClass movieNPClass = {
    NP_CLASS_STRUCT_VERSION,
    movieNPObjectAllocate, // NP_Allocate
    movieNPObjectDeallocate, // NP_Deallocate
    0, // NP_Invalidate
    movieNPObjectHasMethod, // NP_HasMethod
    movieNPObjectInvoke, // NP_Invoke
    0, // NP_InvokeDefault
    0, // NP_HasProperty
    0, // NP_GetProperty
    0, // NP_SetProperty
    0, // NP_RemoveProperty
    0, // NP_Enumerate
    0, // NP_Construct
};

void drawPlugin(NPP instance, NPCocoaEvent* event);

/* Symbol called once by the browser to initialize the plugin. */
NPError NP_Initialize(NPNetscapeFuncs* browserFuncs)
{
    /* Save the browser function table. */
    
    browser = browserFuncs;
    
    
    return NPERR_NO_ERROR;
}

/* Function called by the browser to get the plugin's function table. */
NPError NP_GetEntryPoints(NPPluginFuncs* pluginFuncs)
{
    /* Check the size of the provided structure based on the offset of the
     last member we need. */
    if (pluginFuncs->size < (offsetof(NPPluginFuncs, setvalue) + sizeof(void*)))
        return NPERR_INVALID_FUNCTABLE_ERROR;
    
    pluginFuncs->newp = NPP_New;
    pluginFuncs->destroy = NPP_Destroy;
    pluginFuncs->setwindow = NPP_SetWindow;
    pluginFuncs->newstream = NPP_NewStream;
    pluginFuncs->destroystream = NPP_DestroyStream;
    pluginFuncs->asfile = NPP_StreamAsFile;
    pluginFuncs->writeready = NPP_WriteReady;
    pluginFuncs->write = (NPP_WriteProcPtr)NPP_Write;
    pluginFuncs->print = NPP_Print;
    pluginFuncs->event = NPP_HandleEvent;
    pluginFuncs->urlnotify = NPP_URLNotify;
    pluginFuncs->getvalue = NPP_GetValue;
    pluginFuncs->setvalue = NPP_SetValue;
    return NPERR_NO_ERROR;
}

/* Function called once by the browser to shut down the plugin. */
void NP_Shutdown(void)
{
    CFRelease(browserUAString);
    browserUAString = NULL;
}

/* Called to create a new instance of the plugin. */
NPError NPP_New(NPMIMEType pluginType, NPP instance, uint16_t mode, int16_t argc, char* argn[], char* argv[], NPSavedData* saved)
{
    
    
    
    PluginInstance *newInstance = (PluginInstance*)malloc(sizeof(PluginInstance));
    bzero(newInstance, sizeof(PluginInstance));
    
    newInstance->npp = instance;
    instance->pdata = newInstance;
    
    /* Select the Core Graphics drawing model. */
    NPBool supportsCoreGraphics = false;
    if (browser->getvalue(instance, NPNVsupportsCoreGraphicsBool, &supportsCoreGraphics) == NPERR_NO_ERROR && supportsCoreGraphics) {
        browser->setvalue(instance, NPPVpluginDrawingModel, (void*)NPDrawingModelCoreGraphics);
    } else {
        printf("CoreGraphics drawing model not supported, can't create a plugin instance.\n");
        return NPERR_INCOMPATIBLE_VERSION_ERROR;
    }
    
    /* Select the Cocoa event model. */
    NPBool supportsCocoaEvents = false;
    if (browser->getvalue(instance, NPNVsupportsCocoaBool, &supportsCocoaEvents) == NPERR_NO_ERROR && supportsCocoaEvents) {
        browser->setvalue(instance, NPPVpluginEventModel, (void*)NPEventModelCocoa);
    } else {
        printf("Cocoa event model not supported, can't create a plugin instance.\n");
        return NPERR_INCOMPATIBLE_VERSION_ERROR;
    }
    
    if (!browserUAString) {
        const char* ua = browser->uagent(instance);
        if (ua) {
            browserUAString = CFStringCreateWithCString(kCFAllocatorDefault, ua, kCFStringEncodingASCII);
        }
    }
    
    return NPERR_NO_ERROR;
}

/* Called to destroy an instance of the plugin. */
NPError NPP_Destroy(NPP instance, NPSavedData** save)
{
    free(instance->pdata);
    
    return NPERR_NO_ERROR;
}

/* Called to update a plugin instances's NPWindow. */
NPError NPP_SetWindow(NPP instance, NPWindow* window)
{
    PluginInstance* currentInstance = (PluginInstance*)(instance->pdata);
    
    currentInstance->window = *window;
    
    return NPERR_NO_ERROR;
}

NPError NPP_NewStream(NPP instance, NPMIMEType type, NPStream* stream, NPBool seekable, uint16_t* stype)
{
    *stype = NP_ASFILEONLY;
    return NPERR_NO_ERROR;
}

NPError NPP_DestroyStream(NPP instance, NPStream* stream, NPReason reason)
{
    return NPERR_NO_ERROR;
}

int32_t NPP_WriteReady(NPP instance, NPStream* stream)
{
    return 0;
}

int32_t NPP_Write(NPP instance, NPStream* stream, int32_t offset, int32_t len, void* buffer)
{
    return 0;
}

void NPP_StreamAsFile(NPP instance, NPStream* stream, const char* fname)
{
}

void NPP_Print(NPP instance, NPPrint* platformPrint)
{
    
}

int16_t NPP_HandleEvent(NPP instance, void* event)
{
    
    
    NPCocoaEvent* cocoaEvent = (NPCocoaEvent*)event;
    if (cocoaEvent && (cocoaEvent->type == NPCocoaEventDrawRect)) {
        drawPlugin(instance, (NPCocoaEvent*)event);
        return 1;
    }
    
    return 0;
}

void NPP_URLNotify(NPP instance, const char* url, NPReason reason, void* notifyData)
{
    
}

NPError NPP_GetValue(NPP instance, NPPVariable variable, void *value)
{
    
    
    PluginInstance *obj = instance->pdata;
    
    switch (variable) {
            
        case NPPVpluginScriptableNPObject:
            
            
            // Create the movie NPObject if necessary.
            if (!obj->myNPObject)
                obj->myNPObject = browser->createobject(instance, &movieNPClass);;
            
            // The NPAPI standard specifies that a retained NPObject should be returned.
            *(NPObject **)value = obj->myNPObject;
            browser->retainobject(obj->myNPObject);
            
            return NPERR_NO_ERROR;
        default:
            return NPERR_GENERIC_ERROR;
            
            
            
            
    }
    
    
 
}

NPError NPP_SetValue(NPP instance, NPNVariable variable, void *value)
{
    
    
    return NPERR_GENERIC_ERROR;
}



void drawPlugin(NPP instance, NPCocoaEvent* event)
{
    if (!browserUAString) {
        return;
    }
    
    PluginInstance* currentInstance = (PluginInstance*)(instance->pdata);
    CGContextRef cgContext = event->data.draw.context;
    if (!cgContext) {
        return;
    }
    
    float windowWidth = currentInstance->window.width;
    float windowHeight = currentInstance->window.height;
    
    /* Save the cgcontext gstate. */
    CGContextSaveGState(cgContext);
    
    /* We get a flipped context. */
    CGContextTranslateCTM(cgContext, 0.0, windowHeight);
    CGContextScaleCTM(cgContext, 1.0, -1.0);
    
    /* Draw a gray background for the plugin. */
    CGContextAddRect(cgContext, CGRectMake(0, 0, windowWidth, windowHeight));
    CGContextSetGrayFillColor(cgContext, 0.5, 1.0);
    CGContextDrawPath(cgContext, kCGPathFill);
    
    /* Draw a black frame around the plugin. */
    CGContextAddRect(cgContext, CGRectMake(0, 0, windowWidth, windowHeight));
    CGContextSetGrayStrokeColor(cgContext, 0.0, 1.0);
    CGContextSetLineWidth(cgContext, 6.0);
    CGContextStrokePath(cgContext);
    
    /* Draw the UA string using ATSUI. */
    CGContextSetGrayFillColor(cgContext, 0.0, 1.0);
    ATSUStyle atsuStyle;
    ATSUCreateStyle(&atsuStyle);
    CFIndex stringLength = CFStringGetLength(browserUAString);
    UniChar* unicharBuffer = (UniChar*)malloc((stringLength + 1) * sizeof(UniChar));
    CFStringGetCharacters(browserUAString, CFRangeMake(0, stringLength), unicharBuffer);
    UniCharCount runLengths = kATSUToTextEnd;
    ATSUTextLayout atsuLayout;
    ATSUCreateTextLayoutWithTextPtr(unicharBuffer,
                                    kATSUFromTextBeginning,
                                    kATSUToTextEnd,
                                    stringLength,
                                    1,
                                    &runLengths,
                                    &atsuStyle,
                                    &atsuLayout);
    ATSUAttributeTag contextTag = kATSUCGContextTag;
    ByteCount byteSize = sizeof(CGContextRef);
    ATSUAttributeValuePtr contextATSUPtr = &cgContext;
    ATSUSetLayoutControls(atsuLayout, 1, &contextTag, &byteSize, &contextATSUPtr);
    ATSUTextMeasurement lineAscent, lineDescent;
    ATSUGetLineControl(atsuLayout,
                       kATSUFromTextBeginning,
                       kATSULineAscentTag,
                       sizeof(ATSUTextMeasurement),
                       &lineAscent,
                       &byteSize);
    ATSUGetLineControl(atsuLayout,
                       kATSUFromTextBeginning,
                       kATSULineDescentTag,
                       sizeof(ATSUTextMeasurement),
                       &lineDescent,
                       &byteSize);
    float lineHeight = FixedToFloat(lineAscent) + FixedToFloat(lineDescent);
    ItemCount softBreakCount;
    ATSUBatchBreakLines(atsuLayout,
                        kATSUFromTextBeginning,
                        stringLength,
                        FloatToFixed(windowWidth - 10.0),
                        &softBreakCount);
    ATSUGetSoftLineBreaks(atsuLayout,
                          kATSUFromTextBeginning,
                          kATSUToTextEnd,
                          0, NULL, &softBreakCount);
    UniCharArrayOffset* softBreaks = (UniCharArrayOffset*)malloc(softBreakCount * sizeof(UniCharArrayOffset));
    ATSUGetSoftLineBreaks(atsuLayout,
                          kATSUFromTextBeginning,
                          kATSUToTextEnd,
                          softBreakCount, softBreaks, &softBreakCount);
    UniCharArrayOffset currentDrawOffset = kATSUFromTextBeginning;
    int i = 0;
    while (i < softBreakCount) {
        ATSUDrawText(atsuLayout, currentDrawOffset, softBreaks[i], FloatToFixed(5.0), FloatToFixed(windowHeight - 5.0 - (lineHeight * (i + 1.0))));
        currentDrawOffset = softBreaks[i];
        i++;
    }
    ATSUDrawText(atsuLayout, currentDrawOffset, kATSUToTextEnd, FloatToFixed(5.0), FloatToFixed(windowHeight - 5.0 - (lineHeight * (i + 1.0))));
    free(unicharBuffer);
    free(softBreaks);
    
    /* Restore the cgcontext gstate. */
    CGContextRestoreGState(cgContext);
}


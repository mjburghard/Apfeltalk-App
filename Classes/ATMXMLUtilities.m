//
//  ATMXMLUtilities.m
//  Apfeltalk Magazin
//
//  Created by Alexander v. Below on 21.09.09.
//  Copyright 2009 AVB Software. All rights reserved.
//

#import "ATMXMLUtilities.h"
#import "Story.h"
#import <libxml/HTMLparser.h>
#import <libxml/xpath.h>
#import <libxml/xpathInternals.h>


NSString *const kItemPagesLinksKey = @"pagesLinks";


@implementation ATMXMLUtilities

@synthesize xPaths;


#pragma mark - Object Creation

+ (ATMXMLUtilities *)xmlUtilitiesWithURLString:(NSString *)urlString
{
    return [[[ATMXMLUtilities alloc] initWithURLString:urlString] autorelease];
}


- (id)initWithURLString:(NSString *)urlString
{
    self = [super init];

    if (self)
    {
        theXMLDoc = htmlReadFile([urlString UTF8String], "ISO-8851-1", HTML_PARSE_RECOVER | HTML_PARSE_NOERROR | HTML_PARSE_NOWARNING);
        if (theXMLDoc == NULL)
        {
            [self release];
            self = nil;
        }

        self.xPaths = [NSDictionary dictionaryWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"XPaths" ofType:@"plist"]];
    }

    return self;
}

- (void)dealloc
{
    if (theXMLDoc)
        xmlFreeDoc(theXMLDoc);
    self.xPaths = nil;

    [super dealloc];
}


#pragma mark - Filter methods

- (NSString *)authorName
{
    NSString *result = @"";
    NSString *xPath = [self.xPaths objectForKey:ATStoryAuthor];

    if (xPath)
    {
        xmlXPathContextPtr xpathContext = xmlXPathNewContext(theXMLDoc);
        if (xpathContext)
        {
            xmlXPathObjectPtr xpathObject = xmlXPathEvalExpression((xmlChar *)[xPath UTF8String], xpathContext);
            if (xpathObject)
            {
                if ((xpathObject->type == XPATH_NODESET) && (xpathObject->nodesetval) && (xpathObject->nodesetval->nodeNr == 1))
                {
                    xmlNodePtr node = xpathObject->nodesetval->nodeTab[0];  // The node defined by the XPath
                    if (node->children)
                    {
                        node = node->children;  // The node with the author name
                        if (node->content)
                            result = [NSString stringWithCString:(char *)node->content encoding:NSUTF8StringEncoding];
                    }
                }

                xmlXPathFreeObject(xpathObject);
            }

            xmlXPathFreeContext(xpathContext);
        }
    }

    return result;
}


- (NSString *)articleContent
{
    NSString *result = @"";
    NSString *xPath = [self.xPaths objectForKey:ATStoryContent];

    if (xPath)
    {
        xmlXPathContextPtr xpathContext = xmlXPathNewContext(theXMLDoc);
        if (xpathContext)
        {
            xmlXPathObjectPtr xpathObject = xmlXPathEvalExpression((xmlChar *)[xPath UTF8String], xpathContext);
            if (xpathObject)
            {
                if ((xpathObject->type == XPATH_NODESET) && (xpathObject->nodesetval) && (xpathObject->nodesetval->nodeNr == 1))
                {
                    xmlChar *buffer = NULL;
                    int      bufferSize = 0;

                    xmlNodePtr node = xpathObject->nodesetval->nodeTab[0];  // The node defined by the XPath
                    node = xmlDocSetRootElement(theXMLDoc, node);
                    xmlDocDumpMemoryEnc(theXMLDoc, &buffer, &bufferSize, "UTF-8");
                    xmlDocSetRootElement(theXMLDoc, node);  // Restore the original root element

                    if (buffer)
                    {
                        int location = 1;
                        int lineCount = 0;

                        while ((location < bufferSize) && (lineCount < 2))  // Skip the XML header (first two lines)
                        {
                            if ((buffer[location] == '\n') || buffer[location] == '\r')
                                ++lineCount;
                            if ((buffer[location - 1] == '\r') && buffer[location] == '\n')
                                --lineCount;

                            ++location;
                        }

                        if (location < bufferSize)
                            result = [NSString stringWithCString:(const char *)(buffer + location) encoding:NSUTF8StringEncoding];

                        xmlFree(buffer);
                    }
                }

                xmlXPathFreeObject(xpathObject);
            }

            xmlXPathFreeContext(xpathContext);
        }
    }

    return result;
}


- (NSArray *)articlePagesLinks
{
    NSMutableArray *pagesLinks = nil;
    NSString       *xPath = [self.xPaths objectForKey:kItemPagesLinksKey];

    if (xPath)
    {
        xmlXPathContextPtr xpathContext = xmlXPathNewContext(theXMLDoc);
        if (xpathContext != NULL)
        {
            xmlXPathObjectPtr xpathObject = xmlXPathEvalExpression((xmlChar *)[xPath UTF8String], xpathContext);
            if (xpathObject)
            {
                if ((xpathObject->type == XPATH_NODESET) && (xpathObject->nodesetval) && (xpathObject->nodesetval->nodeNr > 0))
                {
                    xmlNodePtr node = xpathObject->nodesetval->nodeTab[0];  // The first node defined by the XPath
                    xmlNodePtr rootNode = xmlDocSetRootElement(theXMLDoc, node);
                    xmlXPathObjectPtr xpathLinks = xmlXPathEvalExpression((xmlChar *)"//li/a[@href]", xpathContext);

                    if (xpathLinks)
                    {
                        if ((xpathLinks->type == XPATH_NODESET) && (xpathLinks->nodesetval) && (xpathLinks->nodesetval->nodeNr > 0))
                        {
                            pagesLinks = [NSMutableArray array];
                            int index = 0;
                            while (index < xpathLinks->nodesetval->nodeNr)
                            {
                                node = xpathLinks->nodesetval->nodeTab[index++];
                                [pagesLinks addObject:[NSString stringWithCString:(const char *)node->properties->children->content
                                                                         encoding:NSUTF8StringEncoding]];
                            }
                        }

                        xmlXPathFreeObject(xpathLinks);
                    }

                    xmlDocSetRootElement(theXMLDoc, rootNode);  // Restore the original root element
                }

                xmlXPathFreeObject(xpathObject);
            }

            xmlXPathFreeContext(xpathContext);
        }
    }

    return pagesLinks;
}

- (NSInteger)topicIDOfCommentsTopic {
    NSInteger topicID = 0;
    NSString *xPath = @"//form[@id='form_widget_comments']/@action";
    
    NSString *value = [self extractTextForQuery:xPath];
    
    NSLog(@"%@", value);
    
    return topicID;
}

- (NSString *)extractTextForQuery:(NSString *)query {
    NSString *value = nil;
    if (query)
    {
        xmlXPathContextPtr xpathContext = xmlXPathNewContext(theXMLDoc);
        if (xpathContext)
        {
            xmlXPathObjectPtr xpathObject = xmlXPathEvalExpression((xmlChar *)[query UTF8String], xpathContext);
            if (xpathObject)
            {
                if ((xpathObject->type == XPATH_NODESET) && (xpathObject->nodesetval) && (xpathObject->nodesetval->nodeNr == 1))
                {
                    xmlNodePtr node = xpathObject->nodesetval->nodeTab[0];
                    if (node->children)
                    {
                        node = node->children;
                        if (node->content)
                            value = [NSString stringWithCString:(char *)node->content encoding:NSUTF8StringEncoding];
                    }
                }
                
                xmlXPathFreeObject(xpathObject);
            }
            
            xmlXPathFreeContext(xpathContext);
        }
    }
    return value;
}

@end


#pragma mark special XML processing

NSString *extractTextFromHTMLForQuery (NSString *htmlInput, NSString *query)
{
    NSString *value = nil;

    NSData *data = [htmlInput dataUsingEncoding:NSUTF8StringEncoding];
    htmlDocPtr	doc = htmlReadMemory([data bytes],[data length], NULL, NULL, 0);
    // Create xpath evaluation context
    xmlXPathContextPtr xpathCtx = xmlXPathNewContext(doc);

    xmlChar * xpathExpr = (xmlChar*)[query UTF8String];

    xmlXPathObjectPtr xpathObj = xmlXPathEvalExpression(xpathExpr, xpathCtx);
    if(xpathObj == NULL)
    {
        fprintf(stderr,"Error: unable to evaluate xpath expression \"%s\"\n", xpathExpr);
    }
    else
    {
        xmlNodeSetPtr nodeset = xpathObj->nodesetval;
        if (nodeset && nodeset->nodeNr == 1 && nodeset->nodeTab[0]->children)
        {
            xmlNodePtr child = nodeset->nodeTab[0]->children;

            if (child->type == XML_TEXT_NODE)
                value = [NSString stringWithCString:(char*)child->content encoding:NSUTF8StringEncoding];
        }
        xmlXPathFreeObject(xpathObj);
    }

    xmlXPathFreeContext(xpathCtx);
    xmlFreeDoc(doc);
    xmlCleanupParser();

    return value;
}

NSArray *extractNodesFromHTMLForQuery (NSString *htmlInput, NSString *query)
{
    NSMutableArray *array = nil;
    
    NSData *data = [htmlInput dataUsingEncoding:NSUTF8StringEncoding];
    htmlDocPtr	doc = htmlReadMemory([data bytes],[data length], NULL, NULL, 0);
    // Create xpath evaluation context
    xmlXPathContextPtr xpathCtx = xmlXPathNewContext(doc);
    
    xmlChar * xpathExpr = (xmlChar*)[query UTF8String];
    
    xmlXPathObjectPtr xpathObj = xmlXPathEvalExpression(xpathExpr, xpathCtx);
    if(xpathObj == NULL)
    {
        fprintf(stderr,"Error: unable to evaluate xpath expression \"%s\"\n", xpathExpr);
    }
    else
    {
        xmlNodeSetPtr nodeset = xpathObj->nodesetval;
        if (nodeset)
        {
            array = [NSMutableArray array];
            for (int i = 0; i < (nodeset->nodeNr); i++) {
                xmlNodePtr nodeTab = nodeset->nodeTab[i];
                xmlNodePtr child = nodeTab->children;
                if (!child)
                    child = nodeTab;
                [array addObject:[NSString stringWithCString:(char*)child->content encoding:NSUTF8StringEncoding]];
            }
        }
        xmlXPathFreeObject(xpathObj);
    }
    
    xmlXPathFreeContext(xpathCtx);
    xmlFreeDoc(doc);
    xmlCleanupParser();
    
    return array;
}

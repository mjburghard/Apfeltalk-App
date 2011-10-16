//
//  XMLRPCResponseParser.m
//  Apfeltalk Magazin
//
//  Created by Manuel Burghard on 22.08.11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "XMLRPCResponseParser.h"
#import "ContentTranslator.h"

@implementation XMLRPCResponseParser
@synthesize xmlParser;
@synthesize currentString;
@synthesize name;
@synthesize value;
@synthesize valueTypes;
@synthesize currentObject;
@synthesize lastObjects;
@synthesize decodeBase64Data;

@synthesize delegate;

- (id)initWithData:(NSData *)data delegate:(id)_delegate {
    self = [super init];
    if (self) {
        self.delegate = _delegate;
        NSXMLParser *parser = [[NSXMLParser alloc] initWithData:data];
        self.xmlParser = parser;
        [parser release];
        [self.xmlParser setDelegate:self];
        self.decodeBase64Data = YES;
    }
    return self;
}

+ (XMLRPCResponseParser *)parserWithData:(NSData *)data delegate:(id)_delegate {
    return [[[XMLRPCResponseParser alloc] initWithData:data delegate:_delegate] autorelease];
}

- (void)dealloc {
    self.delegate = nil;
    self.decodeBase64Data = NO;
    self.lastObjects = nil;
    self.currentString = nil;
    self.valueTypes = nil;
    self.name = nil;
    self.value = nil;
    self.currentObject = nil;
    self.xmlParser = nil;
    [super dealloc];
}

- (BOOL)parse {
    return [self.xmlParser parse];
}

- (void)abortParsing {
    [self.xmlParser abortParsing];
}

- (void)parserDidFinish {
    if (self.delegate && [(NSObject*)self.delegate respondsToSelector:@selector(parserDidFinishWithObject:ofType:)]) {
        if ([self.currentObject isKindOfClass:[NSMutableDictionary class]]) {
            [self.delegate parserDidFinishWithObject:self.currentObject ofType:XMLRPCResultTypeDictionary];
        } else if ([self.currentObject isKindOfClass:[NSMutableArray class]]) {
            [self.delegate parserDidFinishWithObject:self.currentObject ofType:XMLRPCResultTypeArray];
        }
    }
}

- (void)parseErrorOccurred:(NSError *)parseError {
    if (self.delegate && [(NSObject*)self.delegate respondsToSelector:@selector(parser:parseErrorOccurred:)]) {
        [self.delegate parser:self parseErrorOccurred:parseError];
    }
}

#pragma mark -
#pragma mark NSXMLParserDelegate

- (void)parserDidStartDocument:(NSXMLParser *)parser {
    self.lastObjects = [NSMutableArray array];
    self.valueTypes = [NSArray arrayWithObjects:@"boolean", @"string", @"i4", @"int", @"base64", @"double", @"dateTime.iso8601", nil];
}

- (void)parser:(NSXMLParser *)parser 
didStartElement:(NSString *)elementName 
  namespaceURI:(NSString *)namespaceURI 
 qualifiedName:(NSString *)qName 
    attributes:(NSDictionary *)attributeDict {
    if ([elementName isEqualToString:@"struct"]) {
        NSMutableDictionary *mutableDictionary = [NSMutableDictionary dictionary];
        
        if (self.currentObject) {
            if ([self.currentObject isKindOfClass:[NSMutableDictionary class]]) {
                [(NSMutableDictionary *)self.currentObject setValue:mutableDictionary forKey:self.name];
            } else if ([self.currentObject isKindOfClass:[NSMutableArray class]]) {
                [(NSMutableArray *)self.currentObject addObject:mutableDictionary];
            }
            [self.lastObjects addObject:self.currentObject];
        }
        self.currentObject = mutableDictionary;
    } else if ([elementName isEqualToString:@"array"]) {
        NSMutableArray *mutableArray = [NSMutableArray array];
        if (self.currentObject) {
            if ([self.currentObject isKindOfClass:[NSMutableDictionary class]]) {
               [(NSMutableDictionary *)self.currentObject setValue:mutableArray forKey:self.name]; 
            } else if ([self.currentObject isKindOfClass:[NSMutableArray class]]) {
                [(NSMutableArray *)self.currentObject addObject:mutableArray];
            }
            [self.lastObjects addObject:self.currentObject];
        }
        self.currentObject = mutableArray;
    } else if ([self.valueTypes containsObject:elementName] || [elementName isEqualToString:@"name"]) {
        self.currentString = [NSMutableString string];
    }
}

- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string {
    [self.currentString appendString:string];
}

- (void)parser:(NSXMLParser *)parser 
 didEndElement:(NSString *)elementName 
  namespaceURI:(NSString *)namespaceURI 
 qualifiedName:(NSString *)qName {
    if ([elementName isEqualToString:@"name"]) {
        [self setValue:self.currentString forKey:@"name"];
    } else if ([self.valueTypes containsObject:elementName]) {
        if ([elementName isEqualToString:@"base64"] && self.decodeBase64Data) {
            self.currentString = (NSMutableString *)decodeString(self.currentString);
        }
        [self setValue:self.currentString forKey:@"value"];
    } else if ([elementName isEqualToString:@"value"] && self.value) {
        if ([self.currentObject isKindOfClass:[NSMutableDictionary class]]) {
            [(NSMutableDictionary *)self.currentObject setValue:self.value forKey:self.name];
        } else if ([self.currentObject isKindOfClass:[NSMutableArray class]]) {
            [(NSMutableArray *)self.currentObject addObject:self.value];
        }
    } else if (([elementName isEqualToString:@"struct"] || [elementName isEqualToString:@"array"]) && [self.lastObjects count] > 0) {
        self.value = nil;
        self.name = nil;
        self.currentObject = [self.lastObjects lastObject];
        [self.lastObjects removeLastObject];
    }       
    
    self.currentString = nil;
}

- (void)parserDidEndDocument:(NSXMLParser *)parser {
    [self performSelectorOnMainThread:@selector(parserDidFinish) withObject:nil waitUntilDone:YES];
    
    self.delegate = nil;
    self.decodeBase64Data = NO;
    self.lastObjects = nil;
    self.currentString = nil;
    self.valueTypes = nil;
    self.name = nil;
    self.value = nil;
    self.currentObject = nil;
    self.xmlParser = nil;
}

- (void)parser:(NSXMLParser *)parser parseErrorOccurred:(NSError *)parseError {
    [self performSelectorOnMainThread:@selector(parseErrorOccurred:) withObject:parseError waitUntilDone:YES];
}

@end
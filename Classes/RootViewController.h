//
//  RootViewController.h
//  Apfeltalk Magazin
//
//	Apfeltalk Magazin -- An iPhone Application for the site http://apfeltalk.de
//	Copyright (C) 2009	Stephan König (stephankoenig at me dot com), Stefan Kofler
//						Alexander von Below, Andreas Rami, Michael Fenske, Laurids Düllmann, Jesper Frommherz (Graphics),
//						Patrick Rollbis (Graphics),
//						
//	This program is free software; you can redistribute it and/or
//	modify it under the terms of the GNU General Public License
//	as published by the Free Software Foundation; either version 2
//	of the License, or (at your option) any later version.
//
//	This program is distributed in the hope that it will be useful,
//	but WITHOUT ANY WARRANTY; without even the implied warranty of
//	MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
//	GNU General Public License for more details.
//
//	You should have received a copy of the GNU General Public License
//	along with this program; if not, write to the Free Software
//	Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.//
//

#define kAccelerationThreshold        2.2
#define kUpdateInterval               (1.0f/10.0f)

#import "ATXMLParser.h"
#import <UIKit/UIKit.h>
#import <sqlite3.h>
#import <MessageUI/MessageUI.h>
#import "EGORefreshTableHeaderView.h"
#import "Story.h"

@class DetailViewController;

@protocol SubstitutableDetailViewController
- (void)showRootPopoverButtonItem:(UIBarButtonItem *)barButtonItem;
- (void)invalidateRootPopoverButtonItem:(UIBarButtonItem *)barButtonItem;
@end

@interface RootViewController : UITableViewController <ATXMLParserDelegateProtocol, MFMailComposeViewControllerDelegate, EGORefreshTableHeaderDelegate, UISplitViewControllerDelegate, NSURLConnectionDelegate>
{
	IBOutlet UITableView * newsTable;
	IBOutlet UITableViewCell *loadingCell;
	NSMutableData *xmlData;
	NSArray *stories;
    EGORefreshTableHeaderView *tableHeaderView;
    BOOL reloading;
    BOOL isLoading;
    
    UIPopoverController *popoverController;    
    UIBarButtonItem *rootPopoverButtonItem;

@protected
	sqlite3 * database;
}

@property(retain) NSArray *stories;
@property (readonly) BOOL shakeToReload;
@property (readonly) NSDictionary * desiredKeys;
@property (nonatomic, retain) UIPopoverController *popoverController;
@property (nonatomic, retain) UIBarButtonItem *rootPopoverButtonItem;

- (void)reloadTableViewDataSource;
- (void)doneLoadingTableViewData;

- (NSString *)dateElementName;
- (void)parseXMLFileAtURL:(NSString *)URL;
- (IBAction)openSafari:(id)sender;
- (IBAction)about:(id)sender;

- (NSString *)supportFolderPath;
- (NSString *)documentPath;
- (Class) detailControllerClass;
- (NSString *)detailNibName;
- (void)markStoryAsRead:(Story *)aStory;

- (void)updateApplicationIconBadgeNumber;
- (BOOL)databaseContainsURL:(NSString *)link;
- (BOOL)openDatabase;

- (BOOL)isShake:(UIAcceleration *)acceleration;
- (void)activateShakeToReload:(id)delegate;

- (void)connectionDidFinishLoading:(NSURLConnection *)connection;

@end

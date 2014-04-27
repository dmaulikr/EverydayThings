//
//  Item+Helper.m
//  EverydayThings
//
//  Created by Daisuke Hirata on 2014/04/22.
//  Copyright (c) 2014年 Daisuke Hirata. All rights reserved.
//

#import "AppDelegate.h"
#import "Item+Helper.h"
#import "ItemCategory+Helper.h"

@implementation Item (Helper)


+ (Item *)saveItem:(NSDictionary *)values
{
    Item *item = nil;
    NSManagedObjectContext *context = [AppDelegate sharedContext];
    
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Item"];
    request.predicate = [NSPredicate predicateWithFormat:@"name = %@", values[@"name"]];
    
    NSError *error;
    NSArray *matches = [context executeFetchRequest:request error:&error];
    
    if (!matches || error || ([matches count] > 1)) {
        // error
        item = nil; // not necessary. it's for readability
    } else if  ([matches count]) {
        // update
        item = [matches firstObject];
    } else {
        // insert
        item = [NSEntityDescription insertNewObjectForEntityForName:@"Item"
                                             inManagedObjectContext:context];
    }
    
    if (item) {
        item.name                = values[@"name"];
        item.buyNow              = values[@"buyNow"];
        item.stock               = values[@"stock"];
        item.lastPurchaseDate    = values[@"lastPurchaseDate"];
        item.expireDate          = values[@"expireDate"];
        item.whereToBuy          = values[@"whereToBuy"];
        item.favoriteProductName = values[@"favoriteProductName"];
        item.whereToStock        = values[@"whereToStock"];
        item.cycle               = [values[@"cycle"] length] != 0 ?
                                        [NSDecimalNumber decimalNumberWithString:values[@"cycle"]] : nil;
        item.timeSpan            = [Item timeSpans][[values[@"timeSpan"] intValue]];
        item.whichItemCategory   = [ItemCategory itemCategoryWithIndex:[values[@"category"] intValue]];
        item.elapsed             = [item elapsedDaysAfterLastPurchaseDate] > [item cycleInDays] ? @1 : @0;
        item.location            = values[@"location"];
        item.geofence            = values[@"geofence"];
        
        NSError *error = nil;
        [context save:&error];
        if(error) {
            NSLog(@"could not save data : %@", error);
        }
    }
    
    return item;
}


- (NSInteger)expiredWeeks
{
	// now - expire date
	NSTimeInterval since = 0;
    
    if (self.expireDate) {
        since = [[NSDate date] timeIntervalSinceDate:self.expireDate];
    }
    
    // convert second into week
    return (NSInteger)since/(7*24*60*60);
}

- (NSInteger)elapsedDaysAfterLastPurchaseDate
{
	// now - last purchase date
	NSTimeInterval since = 0;
    
    if (self.lastPurchaseDate) {
        since = [[NSDate date] timeIntervalSinceDate:self.lastPurchaseDate];
    }
    
    // convert second into day
    return (NSInteger)since/(24*60*60);
}

- (NSInteger)cycleInDays
{
    NSInteger cycle = 0;
    
    if (![self.cycle isEqualToNumber:[NSDecimalNumber notANumber]]) {
        cycle = [self.cycle longValue];
        if ([self.timeSpan isEqualToString:@"Month"]) {
            cycle = [self.cycle longValue] * 30;
        } else if ([self.timeSpan isEqualToString:@"Year"]) {
            cycle = [self.cycle longValue] * 365;
        }
    }
    
    return cycle;
}

+ (NSArray *)timeSpans
{
    return @[@"Day", @"Month", @"Year"];
}

@end

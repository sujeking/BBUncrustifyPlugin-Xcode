//
//  XCFLogFileManager.m
//  BBUncrustifyPlugin
//
//  Created by Benoît Bourdon on 15/04/15.
//
//

#import "XCFLogFileManager.h"

NSString * const XCFLoggingFileApplicationName = @"BBUncrustifyLogging";

@interface XCFLogFileManager()
@property (nonatomic) NSDateFormatter *loggingFileDateFormatter;
@end

@implementation XCFLogFileManager

@synthesize loggingFileDateFormatter = _loggingFileDateFormatter;

- (NSString *)appName {
	return XCFLoggingFileApplicationName;
}

- (NSString *)newLogFileName {
	NSString *appName = [self appName];
	
	NSDateFormatter *dateFormatter = [self loggingFileDateFormatter];
	NSString *formattedDate = [dateFormatter stringFromDate:[NSDate date]];
	
	return [NSString stringWithFormat:@"%@ %@.log", appName, formattedDate];
}

- (BOOL)isLogFile:(NSString *)fileName {
	NSString *appName = [self appName];
	
	BOOL hasProperPrefix = [fileName hasPrefix:appName];
	BOOL hasProperSuffix = [fileName hasSuffix:@".log"];
	BOOL hasProperDate = NO;
	
	if (hasProperPrefix && hasProperSuffix) {
		NSUInteger lengthOfMiddle = fileName.length - appName.length - @".log".length;
		
		// Date string should have at least 16 characters - " 2013-12-03 17-14"
		if (lengthOfMiddle >= 17) {
			NSRange range = NSMakeRange(appName.length, lengthOfMiddle);
			
			NSString *middle = [fileName substringWithRange:range];
			NSArray *components = [middle componentsSeparatedByString:@" "];
			
			// When creating logfile if there is existing file with the same name, we append attemp number at the end.
			// Thats why here we can have three or four components. For details see createNewLogFile method.
			//
			// Components:
			//     "", "2013-12-03", "17-14"
			// or
			//     "", "2013-12-03", "17-14", "1"
			if (components.count == 3 || components.count == 4) {
				NSString *dateString = [NSString stringWithFormat:@"%@ %@", components[1], components[2]];
				NSDateFormatter *dateFormatter = [self loggingFileDateFormatter];
				
				NSDate *date = [dateFormatter dateFromString:dateString];
				
				if (date) {
					hasProperDate = YES;
				}
			}
		}
	}
	
	return (hasProperPrefix && hasProperDate && hasProperSuffix);
}

- (NSDateFormatter *)loggingFileDateFormatter {
	if (!_loggingFileDateFormatter) {
		NSString *dateFormat = @"yyyy'-'MM'-'dd' 'HH'-'mm'";
		
		NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
		[dateFormatter setLocale:[NSLocale localeWithLocaleIdentifier:@"en_US_POSIX"]];
		[dateFormatter setDateFormat:dateFormat];
		[dateFormatter setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
		_loggingFileDateFormatter = dateFormatter;
	}
	
	return _loggingFileDateFormatter;
}

@end
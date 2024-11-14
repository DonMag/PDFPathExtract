//
//  Extractor.h
//  PDFPathExtract
//
//  Created by Don Mag on 11/14/24.
//

#import <Foundation/Foundation.h>
#import <PDFKit/PDFKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface Extractor : NSObject
+ (NSArray<id> *)extractVectorPathsFromPDF:(NSURL *)pdfURL;
@end

NS_ASSUME_NONNULL_END

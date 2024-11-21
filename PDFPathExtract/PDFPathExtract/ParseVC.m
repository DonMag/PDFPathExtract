//
//  ParseVC.m
//  PDFPathExtract
//
//  Created by Don Mag on 11/15/24.
//

#import "ParseVC.h"
#import <QuartzCore/QuartzCore.h>	// for CAShapeLayer

@interface ParseVC ()

@end

@implementation ParseVC

- (void)viewDidLoad {
	[super viewDidLoad];
	self.view.wantsLayer = YES;
	
}
- (NSString *)loadTextFileFromBundle:(NSString *)fileName withExtension:(NSString *)extension {
	// Get the path to the file in the bundle
	NSString *filePath = [[NSBundle mainBundle] pathForResource:fileName ofType:extension];
	
	if (!filePath) {
		NSLog(@"File not found: %@.%@", fileName, extension);
		return nil;
	}
	
	NSError *error = nil;
	// Load the file's content into a string
	NSString *fileContents = [NSString stringWithContentsOfFile:filePath encoding:NSUTF8StringEncoding error:&error];
	
	if (error) {
		NSLog(@"Error reading file: %@.%@, %@", fileName, extension, error.localizedDescription);
		return nil;
	}
	
	return fileContents;
}

- (void)mouseUp:(NSEvent *)event {

	NSString *input = [self loadTextFileFromBundle:@"uC130" withExtension:@"svg"];
	
	NSScanner *scanner = [NSScanner scannerWithString:input];
	scanner.locale = [NSLocale localeWithLocaleIdentifier:@"en_US_POSIX"];

	NSMutableArray *parsedCommands = [NSMutableArray array];
	
	while (![scanner isAtEnd]) {
		NSLog(@"Scan location: %lu, Remaining: %@", (unsigned long)[scanner scanLocation], [input substringFromIndex:[scanner scanLocation]]);
		// Read the command letter (e.g., 'M', 'L')
		NSString *command = nil;
		if ([scanner scanCharactersFromSet:[NSCharacterSet letterCharacterSet] intoString:&command]) {
			NSMutableArray *points = [NSMutableArray array];
			
			while (![scanner isAtEnd]) {
				// Try to scan the X value
				float x = 0.0, y = 0.0;
				if ([scanner scanFloat:&x]) {
					// Skip the comma
					if ([scanner scanString:@"," intoString:NULL]) {
						// Try to scan the Y value
						if ([scanner scanFloat:&y]) {
							[points addObject:@[@(x), @(y)]];
						} else {
							NSLog(@"Failed to scan 'y' after x = %f at position %lu", x, (unsigned long)[scanner scanLocation]);
							break;
						}
					} else {
						NSLog(@"Failed to find a comma after x = %f at position %lu", x, (unsigned long)[scanner scanLocation]);
						break;
					}
				} else {
					NSLog(@"Failed to scan 'x' at position %lu", (unsigned long)[scanner scanLocation]);
					break;
				}
			}
			
			[parsedCommands addObject:@{@"command": command, @"points": points}];
		}
	}

	for (NSDictionary *command in parsedCommands) {
		NSLog(@"Command: %@, Points: %@", command[@"command"], command[@"points"]);
	}
}

- (void)xmouseUp:(NSEvent *)event {

	NSString *input = @"M268.081,100 C268.081,100 316.424333,167.020633 413.111,301.0619 L611.471,301.0619 C678.121,301.0619 674.201,378.9183 611.471,378.9183 L411.871,378.9183 L255.021,580 L185.89,580 L267,457.5 L266.761,378.9183 L117.95,378.9183 L72.29,431.957 L20,431.957 L47.51,340.0695 L21.32,237.7031 L72.29,237.7031 L119.3,301.0619 L268.081,301.1413 L267,212 L198.94,100 L268.081,100 Z";
	input = @"M268.081,100 C268.081,100 316.424333,167.020633 413.111,301.0619 L611.471,301.0619 C678.121,301.0619 674.201,378.9183 611.471,378.9183 L411.871,378.9183 L255.021,580 L185.89,580 L267,457.5 L266.761,378.9183 L117.95,378.9183 L72.29,431.957 L20,431.957 L47.51,340.0695 L21.32,237.7031 L72.29,237.7031 L119.3,301.0619 L268.081,301.1413 L267,212 L198.94,100 L268.081,100 Z M525.5,239.5 L525.5,276 L446.5,276 L446.5,239.5 L525.5,239.5 Z";
	input = @"M25.5996254,21.3086938 L24.9009571,21.3061664 L24.9558754,21.4266625 C25.0354107,21.5730708 25.0894929,21.8950457 25.1235019,22.1771815 L25.1510192,22.4380597 L25.1707191,22.6891625 L25.1042495,27.5977904 L29.3800941,27.4117187 L30.4785723,27.3768847 L34.0666259,27.3008855 C34.196356,27.2986521 34.3263907,27.2964513 34.4565175,27.2942838 L34.2918129,26.4321313 L34.2843811,25.6044925 L34.2729548,25.12715 C34.2628951,24.8098694 34.2474757,24.5117983 34.2238441,24.3368188 C34.1948728,24.121975 34.2228676,23.8006588 34.267647,23.4720523 L34.3268674,23.0805728 L34.4062624,22.6008215 L34.4357687,22.3993197 C34.4393623,22.3705407 34.4422035,22.3443871 34.4441566,22.3211938 C34.4695473,22.011949 34.6148381,21.8047007 34.6480954,21.5321674 L34.6547769,21.2956254 L33.2746254,21.2790063 C33.106194,21.2743004 32.8913559,21.24927 32.664015,21.2144137 L32.3178647,21.156072 L31.8190993,21.0581481 L31.1957191,20.91885 L32.8160316,20.7352563 L34.8330045,20.6949632 L34.9410082,20.4349985 L35.0614764,20.1729944 L35.1874565,19.9242335 L35.3119954,19.703999 C35.4334963,19.5031218 35.5424063,19.3679584 35.6074379,19.3672816 C35.7654848,19.366192 35.9798051,19.668287 36.094173,19.849642 L36.1738441,19.9829125 L36.3493736,20.5476394 C36.3616431,20.5856903 36.3742374,20.6244301 36.3870458,20.6634365 L36.9002905,20.6450802 C36.9632162,20.6425079 37.0281011,20.6397551 37.0949379,20.6368188 L37.4057892,20.6307591 L37.7461271,20.6363682 L38.1043935,20.651421 L38.6501265,20.686839 L39.1711856,20.7309879 L40.2402504,20.8461938 L39.2674486,21.0122392 L38.6619377,21.1034487 L38.2761879,21.1501 L37.9647855,21.1858872 L37.7125773,21.2243369 L37.521113,21.2605186 L37.3183754,21.3086938 L36.6188323,21.3061628 L36.6746254,21.4266625 C36.7541607,21.5730708 36.8082429,21.8950457 36.8422519,22.1771815 L36.8851001,22.6245106 L36.8894691,22.6891625 L36.8278219,27.2581221 L41.0691566,27.20625 L41.1500263,26.5967452 L41.1980925,26.1757835 L41.2632178,25.5001707 L41.3056292,24.9335246 L41.3277504,24.5382812 C41.3730274,23.5842685 41.7575186,23.2255149 41.997611,23.0938011 L42.0848003,23.0523516 L42.1497091,23.0298827 L42.1902504,23.0203125 L42.4582191,10.1335937 C42.5081931,7.93028646 43.092773,6.5085191 43.6556573,5.54022665 L43.8320402,5.24914141 L44.0030877,4.98590825 L44.4452872,4.34036293 C44.4656002,4.30974045 44.4850421,4.27989583 44.5035316,4.25078125 C44.7500594,3.86293403 45.0348588,3.23419174 45.2783687,2.60721558 L45.4520163,2.14110618 L45.6027214,1.69840856 C45.7394691,1.275 45.830615,0.920833333 45.8425941,0.73828125 C45.8678383,0.361230469 46.5226753,0.153671265 46.9294832,0.0607681274 L47.2480629,0 L47.3782754,0.02396875 L47.5732944,0.0691261574 C47.9461532,0.165538194 48.5095212,0.37109375 48.5340004,0.73671875 C48.5707191,1.284375 49.3191566,3.37578125 49.8738441,4.24921875 L50.0637707,4.5320625 L50.3742781,4.98402431 L50.5453144,5.24723437 C51.1555394,6.21591406 51.8636879,7.69679687 51.9183754,10.1320312 L52.1863441,23.01875 L52.2561929,23.0375094 L52.3331763,23.068814 L52.4290188,23.1217177 C52.6692987,23.2744318 53.0073669,23.6463068 53.0496254,24.5367187 L53.0776495,25.0215407 L53.1129702,25.4846079 L53.1729111,26.1143577 L53.2319863,26.6332884 L53.3082191,27.2046875 L57.5488864,27.2565514 L57.4880254,22.6732046 L57.5111337,22.390531 L57.5356605,22.1646484 L57.5698015,21.9210681 C57.6024594,21.7187659 57.6458865,21.5282366 57.7019691,21.425 C57.718637,21.3943873 57.7373703,21.3541358 57.7575468,21.3066231 L57.0582191,21.3070312 L56.8554815,21.2588561 L56.6640172,21.2226744 L56.411809,21.1842247 C56.3647984,21.1779014 56.3153214,21.1716889 56.2634102,21.1656902 L55.9833622,21.1360029 L55.5680219,21.081048 L54.9582404,20.9860736 L54.1363441,20.8445312 L54.891007,20.7598997 L55.5481138,20.6992936 L56.0899564,20.6601308 C56.1508095,20.6564035 56.211638,20.6529306 56.272201,20.6497585 L56.6304675,20.6347057 C56.6890055,20.6329221 56.7467966,20.6315319 56.8035998,20.6305816 L57.1306392,20.6305287 L57.9906578,20.6623474 L58.2027504,19.98125 L58.2824215,19.8479795 L58.4012855,19.6728508 C58.5146644,19.5187485 58.656266,19.3648408 58.7691566,19.3656191 C58.8450658,19.3664091 58.98076,19.5504388 59.1264787,19.8083307 L59.2526749,20.0449185 C59.2737299,20.0865142 59.2946993,20.1289796 59.3154381,20.1719956 L59.4359426,20.4341498 C59.4744145,20.5220368 59.5108032,20.6095756 59.5439482,20.6942151 L61.5605629,20.7335937 L63.1808754,20.9171875 L62.6145108,21.0444826 L62.1559797,21.1364241 C62.1022034,21.1465344 62.0479207,21.1564744 61.9935683,21.1661089 L61.6701079,21.219169 L61.3659241,21.2584099 C61.2700703,21.2684662 61.1809213,21.2751379 61.1019691,21.2773437 L60.3016139,21.2891519 L59.7223135,21.2939593 C59.7245064,21.3192193 59.7250974,21.3400011 59.7238441,21.3578125 C59.6988441,21.7242187 59.9019691,21.9484375 59.9324379,22.3195312 L59.9408258,22.3976572 L59.9898231,22.7185181 L60.0803871,23.2731445 L60.1334796,23.6658854 C60.1626462,23.9232639 60.1759275,24.1632812 60.1527504,24.3351562 L60.1317779,24.5469558 L60.1156329,24.8175911 L60.1036844,25.1240795 L60.093997,25.5068323 L60.0847816,26.4304687 L59.9203479,27.2924842 L63.5839626,27.3669646 L65.6925521,27.4383883 L69.2722257,27.5962187 L69.2067754,22.6732046 L69.2298837,22.390531 L69.2544105,22.1646484 L69.2885515,21.9210681 C69.3212094,21.7187659 69.3646365,21.5282366 69.4207191,21.425 C69.437387,21.3943873 69.4561203,21.3541358 69.4762968,21.3066231 L68.7769691,21.3070312 L68.7034025,21.2878393 L68.5742315,21.2588561 L68.3827672,21.2226744 L68.130559,21.1842247 C68.0835484,21.1779014 68.0340714,21.1716889 67.9821602,21.1656902 L67.6708191,21.1323598 L67.3239823,21.0864146 L66.7018471,20.9901463 L65.8550941,20.8445312 L66.609757,20.7598997 L67.2668638,20.6992936 L67.8087064,20.6601308 C67.8695595,20.6564035 67.930388,20.6529306 67.990951,20.6497585 L68.3492175,20.6347057 C68.4077555,20.6329221 68.4655466,20.6315319 68.5223498,20.6305816 L68.8493892,20.6305287 L69.7084339,20.6623159 L69.9215004,19.98125 L70.0011715,19.8479795 C70.1155394,19.6666245 70.3298598,19.3645295 70.4879066,19.3656191 C70.5638158,19.3664091 70.69951,19.5504388 70.8452287,19.8083307 L70.9714249,20.0449185 C70.9924799,20.0865142 71.0134493,20.1289796 71.0341881,20.1719956 L71.1546926,20.4341498 C71.1931645,20.5220368 71.2295532,20.6095756 71.2626982,20.6942151 L73.2793129,20.7335937 L74.8996254,20.9171875 L74.3332608,21.0444826 L73.8747297,21.1364241 C73.8209534,21.1465344 73.7666707,21.1564744 73.7123183,21.1661089 L73.3888579,21.219169 L73.0846741,21.2584099 C72.9888203,21.2684662 72.8996713,21.2751379 72.8207191,21.2773437 L72.019778,21.2891576 L71.4400613,21.2939665 L71.4425941,21.3578125 C71.4175941,21.7242188 71.6207191,21.9484375 71.6511879,22.3195313 L71.6595758,22.3976572 L71.7085731,22.7185181 L71.7991371,23.2731445 L71.8522296,23.6658854 C71.8813962,23.9232639 71.8946775,24.1632813 71.8715004,24.3351563 C71.8543221,24.4623529 71.8414832,24.6545933 71.8318881,24.8719743 L71.8166982,25.328434 L71.8058714,25.9836479 L71.8035316,26.4304688 L71.6060356,27.4602794 L71.5577176,27.7004717 L93.0853636,28.6959196 L93.1664518,28.6822645 L93.2401344,28.6773269 L93.3308672,28.6795848 C93.7228563,28.7089424 94.4332902,29.0178267 94.3730629,30.8882812 L94.3259353,32.0595462 L94.2842813,32.7825007 L94.2230265,33.551627 L94.1732435,33.9954517 L94.1441566,34.184375 L61.8251668,38.4747926 L61.5521159,38.5163998 L61.2450443,38.5536 L60.8322458,38.5928703 L60.4989978,38.617329 L60.1197925,38.6384005 L59.6950429,38.6543618 L59.2251621,38.6634901 L58.7105629,38.6640625 L57.9438308,38.6617059 L52.1566566,38.7273437 L52.1044349,46.2121498 L52.0611421,47.5475311 L52.0134117,48.5439671 L51.9593886,49.405011 L51.9084093,50.0534704 L51.8690047,50.4746956 L51.8011879,51.0734375 L51.6618726,52.2005633 L51.4402504,54.234375 L63.9401333,57.0773539 L64.0847155,57.1172425 L64.2670461,57.1785403 C64.8261829,57.3855187 65.7003441,57.8881875 65.7035316,59.0085937 L65.6996094,59.4080374 C65.6981504,59.469636 65.6963149,59.5288079 65.694142,59.5856446 L65.6773697,59.8993725 L65.6543808,60.1614428 L65.6270553,60.3762444 L65.5972734,60.5481661 C65.5922095,60.5734903 65.5871216,60.5972106 65.5820488,60.6194186 L65.5521074,60.7352499 L65.5244098,60.8191736 L65.503493,60.869883 L65.4728864,60.9276126 L65.4760688,60.9640464 L65.4719684,61.0087216 L65.4560192,61.0664912 L65.4223316,61.1346 L65.365016,61.2102928 C65.2228304,61.3674256 64.9035392,61.5535312 64.1951168,61.6694224 L63.9133031,61.7094211 L62.387531,61.8831189 L58.8400692,62.255199 L52.1582191,62.9304687 L50.4385977,63.1734971 L50.2544251,63.2090887 C49.6599027,63.3357426 48.511514,63.6932065 48.4433754,64.5726562 L48.3825661,65.2981454 L48.3050218,66.0555845 L48.2764732,66.270491 L48.2590287,66.3301576 C48.201643,66.490572 47.9992282,66.8299805 47.3066566,66.8921875 C46.6978025,66.8375 46.3625594,66.5692708 46.2067145,66.3965278 L46.1339816,66.3068125 L46.0957191,66.2476562 L46.0210831,65.5799151 L45.9655201,64.9652009 L45.9340004,64.5742188 C45.8738781,63.7982337 44.9723983,63.4286389 44.3525557,63.2654105 L44.1223012,63.2106512 L43.8681845,63.1635626 L42.2183754,62.9320312 L32.9645241,61.9890341 L30.5761942,61.7250556 L30.3668129,61.6984375 C29.3338129,61.5604375 29.0240129,61.2832375 28.9348337,61.1015383 L28.9107515,61.0383361 L28.9014629,60.9868375 L28.903014,60.9257284 L28.8854113,60.8971186 L28.8521847,60.8213663 L28.8244871,60.7373752 L28.7945457,60.6214827 L28.7642406,60.4693091 L28.7354519,60.2764749 L28.7100597,60.0386003 L28.6899441,59.7513057 L28.6769851,59.4102113 C28.6740671,59.2870599 28.6726553,59.154212 28.6730629,59.0109375 C28.6760629,57.9559375 29.4505829,57.4484575 30.0078485,57.2197999 L30.2047081,57.1465983 C30.235177,57.1364014 30.2643144,57.1271624 30.291879,57.1188158 L30.4364612,57.0789196 L30.5660316,57.0507812 L42.9363441,54.2359375 L42.7811358,52.7712384 L42.6062034,51.3174675 L42.549886,50.8663146 L42.5029883,50.4301522 L42.4424597,49.744239 L42.392847,49.0448181 L42.3419938,48.1388749 L42.2885873,46.8100501 L42.2691566,46.0710937 L42.2199379,38.7289062 L39.2459099,38.6849408 L36.6459793,38.6636377 L35.389641,38.6664958 L34.8739192,38.6607001 L34.4080118,38.6465294 L33.9924004,38.6259932 L33.6275667,38.601101 L33.0521592,38.5462865 L32.6271049,38.48906 L32.5269691,38.471875 L0.232437884,34.1859375 L0.188908398,33.8815322 L0.153850585,33.5531895 L0.113654185,33.0802683 L0.0716157662,32.4450803 L0.0408612188,31.8515611 L0.00353163371,30.8898437 C-0.0486700708,29.2536932 0.488849299,28.8124871 0.886675182,28.7079604 L0.995908441,28.6865156 L1.09375876,28.6789451 L1.17644556,28.6808004 L1.30137509,28.6981726 L22.8187837,27.7013527 L22.6229962,26.6981709 L22.5730629,26.4321313 L22.5671067,25.6944107 L22.5541601,25.125742 L22.5393385,24.7615228 L22.5182923,24.4555511 C22.5142053,24.4116161 22.5098134,24.3717629 22.5050941,24.3368188 C22.4761228,24.121975 22.5041176,23.8006588 22.548897,23.4720523 L22.6389483,22.8941104 L22.6934079,22.563544 C22.7086749,22.465942 22.7201983,22.3830427 22.7254066,22.3211938 C22.7507973,22.011949 22.8960881,21.8047007 22.9293454,21.5321674 L22.9360269,21.2956254 L21.5558754,21.2790063 C21.4374471,21.2756974 21.296076,21.2623405 21.1435476,21.2425849 L20.8271065,21.1956234 L20.5018648,21.1380866 L20.0433337,21.0461451 L19.4769691,20.91885 L21.0972816,20.7352563 L23.1142545,20.6949632 L23.2222582,20.4349985 L23.3427264,20.1729944 L23.4687065,19.9242335 C23.6372642,19.6081737 23.8019791,19.3681839 23.8886879,19.3672816 C24.0467348,19.366192 24.2610551,19.668287 24.375423,19.849642 L24.4550941,19.9829125 L24.6306236,20.5476394 C24.6428931,20.5856903 24.6554874,20.6244301 24.6682958,20.6634365 L25.1812561,20.645092 C25.2442603,20.6425167 25.309245,20.6397598 25.3761879,20.6368188 L25.6870392,20.6307591 L26.0273771,20.6363682 L26.3856435,20.651421 L26.9313765,20.686839 L27.4524356,20.7309879 L28.5215004,20.8461938 L27.5486986,21.0122392 L26.9431877,21.1034487 L26.5574379,21.1501 L26.2460355,21.1858872 L25.9938273,21.2243369 L25.802363,21.2605186 L25.5996254,21.3086938 Z";
	input = @"M199.437256,65.5058613 C196.053656,65.5058613 193.580837,68.68756 191.938802,74.9733731 L191.74574,75.7425655 L191.560623,76.5415276 L191.38342,77.3702295 C191.354544,77.5108232 191.325997,77.6526548 191.297777,77.7957237 L191.132388,78.6689797 C191.051655,79.1130265 190.973862,79.5681979 190.89899,80.034477 L190.753136,80.9818407 C190.729475,81.1422014 190.706137,81.3037951 190.683121,81.4666211 L190.429355,82.5334119 L190.325,82.96 L190.171213,83.1583873 L190.049757,83.3326069 C184.134539,89.9722577 181.136446,99.1626952 179.672508,112.23174 L179.538268,113.479623 L179.245476,116.607 L179.14267,117.861164 L179.08,140.461 L178.843348,140.394449 C178.500847,140.309025 178.148252,140.266 177.789,140.266 C175.325018,140.266 173.336,142.317588 173.336,144.844 C173.336,147.371029 175.325601,149.426 177.789,149.426 L178.052268,149.418085 C178.314258,149.40229 178.57216,149.362961 178.823703,149.301044 L179.057,149.235 L179.05,152.045 L178.949678,152.079099 L178.766649,152.151758 C176.035332,153.315972 173.950713,157.803511 174.035072,162.785465 L174.035,170.338 L145.369,170.931 L145.27602,169.148537 L145.188126,167.589136 L145.098026,166.104511 L145.004608,164.682992 L144.906759,163.312913 L144.803365,161.982603 L144.736207,161.191693 L144.565152,159.307297 L144.427147,157.94654 L144.35726,157.305406 L144.285522,156.677466 L144.136374,155.461389 L143.979476,154.298749 C143.738205,152.595087 143.470014,151.073258 143.171455,149.739939 L143.116,149.5 L157,149.499989 L157,147.500003 L142.586,147.499 L142.512935,147.264924 C141.652448,144.571292 140.579611,143.095452 139.141742,143.04728 L138.978663,143.061727 C137.525653,143.239752 136.467632,144.711359 135.657844,147.275583 L135.588,147.499 L121,147.500003 L121,149.500004 L135.074,149.499 L135.017236,149.763212 C134.504844,152.186874 134.125778,155.217785 133.866636,158.755977 L133.811824,159.53794 L133.716312,161.116816 L133.656623,162.311052 L133.611688,163.327216 L133.570609,164.412849 C133.507321,166.234743 133.469729,168.118103 133.455069,170.046935 L133.449,171.178 L118.839,171.478 L118.873887,171.95466 C118.339201,163.953764 116.850101,157.416957 114.274127,152.539496 L114.13338,152.273 L112.225577,152.273 L111.839644,153.025138 L111.617154,153.481403 C109.423049,158.091173 108.15163,164.11335 107.685687,171.434744 L107.669,171.708 L94.164,171.986 L94.0996906,170.651137 L94.0006899,168.754831 L93.074569,156.873332 L92.9155314,155.530108 L92.8400893,154.939005 C92.5854814,152.990496 92.2993847,151.260617 91.9773853,149.758466 L91.92,149.5 L106,149.499979 L106,147.499997 L91.415,147.5 L91.2690414,147.013406 L91.0949251,146.485614 C90.2590047,144.073052 89.2283169,142.740934 87.8687803,142.695282 L87.7050496,142.709807 C86.1921572,142.895586 85.1046721,144.484644 84.281969,147.258532 L84.211,147.5 L69.5,147.5 L69.5,149.49999 L83.726,149.5 L83.6636,149.803147 C83.1918903,152.160264 82.8394981,155.056643 82.5953245,158.404631 L82.5402321,159.18792 L82.1771899,170.221874 L82.1734198,171.476897 L82.175,172.233 L10.9346859,173.703106 C6.78223247,174.112055 5.1487124,178.576411 5.52899469,185.099876 L5.57742208,185.806607 C5.58676996,185.925678 5.59675424,186.045383 5.60737204,186.165711 L5.6786582,186.895056 C5.69179861,187.017829 5.7055668,187.141201 5.71995988,187.265161 L5.81379415,188.015894 L5.92248791,188.780202 L6.04590311,189.557541 L6.18390168,190.347365 L6.39876998,191.462177 L6.53665229,192.137837 L6.67031626,192.759647 L6.79982379,193.32777 L6.92523682,193.842369 L7.04661724,194.303605 C7.06651471,194.37604 7.08624672,194.446259 7.10581458,194.514264 L7.2212622,194.895762 C7.259095,195.014094 7.2962815,195.123599 7.33283202,195.224305 C8.04603105,197.189359 8.78472015,198.76734 9.45587855,199.831469 L9.55780663,199.990453 C10.1645815,200.920658 10.685867,201.419106 11.171,201.203 L110.861,214.193 L113.152028,228.720784 L115.608,214.815 L142.642437,218.335814 L173.781,217.921 L175.304,220.383 L168.088,220.17 L165.725419,219.483817 L165.480058,219.992464 C165.334917,220.317485 165.305792,220.553777 165.347491,220.895044 L165.454086,221.631742 L168.038063,221.476095 L176.288,221.971 L178.859,226.123 L178.837,235.332 L167.977,235.332 L167.977,234.871 L160.426,234.871 L160.426,237.812 L167.977,237.812 L167.977,237.441 L178.831,237.441 L178.751,268.611 L176.809584,270.388692 L176.779,271.844 L176.670871,271.807428 C176.411107,271.72849 176.139893,271.688 175.863,271.688 C174.403437,271.688 173.207,272.801634 173.207,274.195 C173.207,275.589171 174.403236,276.703 175.863,276.703 L176.086313,276.694217 C176.234102,276.682555 176.379515,276.659374 176.521335,276.625255 L176.687,276.578 L176.655712,278.131581 L178.719,280.104 L178.715001,281.728912 L178.729763,281.850601 L178.806363,282.158801 C179.014452,282.914658 179.299527,283.512177 179.793907,284.338669 L180.102549,284.85174 L180.904175,286.490551 L180.962433,286.670318 C181.368012,288.002499 181.315201,289.705818 180.637178,292.197481 L180.518,292.62 L121.098,303.158873 L121.098,318.166121 L185.075562,327.533725 L185.565886,327.537095 C188.164513,327.575894 190.176316,328.554492 192.40693,330.52543 L192.874503,330.948612 L193.326062,331.372923 L194.206751,332.221183 L194.855057,332.836644 C196.818646,334.660394 198.233863,335.412925 200.030348,335.220146 L200.480946,335.171793 L200.48,335.144 L200.674958,335.130959 C202.071213,334.998922 203.291591,334.23672 204.895859,332.748401 L205.327888,332.341122 L206.432983,331.278985 L206.886968,330.853197 L207.352124,330.432988 C209.687403,328.372717 211.804339,327.387861 214.597366,327.452865 L278.656,318.096226 L278.656,303.111741 L219.236,292.592 L219.118585,292.175095 C218.306317,289.193633 218.380214,287.402498 219.112466,285.835811 L219.241721,285.572763 L220.117011,284.059004 L220.249052,283.825935 C220.62298,283.148822 220.871042,282.537699 221.027094,281.835465 L221.038999,281.726151 L221.034,279.584 L223.527371,277.197262 L223.495,275.674 L223.58712,275.700423 C223.778782,275.746679 223.975541,275.77 224.176,275.77 C225.561598,275.77 226.688,274.64669 226.688,273.262 C226.688,271.879843 225.561132,270.758 224.176,270.758 L223.983734,270.765217 C223.79282,270.7796 223.606283,270.815328 223.427004,270.871026 L223.401,270.88 L223.374768,269.456098 L221.002,267.283 L220.894,226.84 L227.079,217.952 L258.165207,218.374954 L291.496,214.035 L294.026486,230.138407 L296.945,213.322 L389.888614,201.210807 L390.060465,201.15555 L391.031318,200.634446 C391.574362,200.246819 392.240246,198.975941 392.83003,197.510323 L393.047244,196.952933 C393.082722,196.858962 393.117805,196.764566 393.152446,196.669913 L393.354587,196.100267 L393.543764,195.532534 L393.717647,194.974785 C393.745224,194.883107 393.772066,194.792181 393.798125,194.702175 L393.944696,194.174529 C393.990162,194.003224 394.032108,193.836945 394.070144,193.677037 L394.188108,193.142911 L394.334462,192.391352 L394.552364,191.16418 L394.809295,189.616497 L395.043074,188.146992 L395.093018,187.756068 C395.141031,187.367098 395.183246,186.984019 395.219588,186.60712 L395.284419,185.861647 L395.333454,185.133167 C395.710146,178.534885 394.079224,174.143089 389.979351,173.736441 L324.727,172.389 L324.607412,169.926665 L324.497146,167.494988 L324.396512,165.557998 L324.334776,164.541718 L324.298516,164.015722 L324.213095,162.919791 L324.110472,161.765256 L323.990651,160.552095 L323.857106,159.060789 L323.791586,158.381227 C323.459478,155.016398 323.059351,152.146843 322.573909,149.799494 L322.51,149.5 L336.5,149.499975 L336.5,147.500003 L322.022,147.499 L321.964752,147.290539 C321.070145,144.182601 319.944391,142.474917 318.395985,142.422289 L318.233097,142.436965 C316.674109,142.63026 315.565292,144.312018 314.73377,147.251017 L314.664,147.5 L300.5,147.499979 L300.5,149.500004 L314.198,149.499 L314.150377,149.742644 C313.766236,151.716879 313.464057,154.05049 313.237197,156.686828 L313.137816,157.924889 L313.048986,159.204703 L312.970562,160.525033 L312.902398,161.88464 L312.84435,163.282288 L312.785664,165.087052 L312.751101,166.525453 C312.721325,167.973024 312.705759,169.447552 312.703001,170.944078 L312.703,172.141 L299.633,171.872 L299.612502,171.622231 C298.984942,164.390706 297.532712,158.446391 295.145108,153.926461 L295.004353,153.66 L293.096753,153.66 L292.710861,154.41111 L292.488064,154.867485 C290.510678,159.017539 289.282616,164.318892 288.717886,170.687531 L288.638,171.646 L273.418,171.334 L273.264323,167.853794 L273.190008,166.380354 L273.100133,164.829423 L273.028659,163.793378 L272.880004,161.9717 L272.633505,159.287765 L272.359573,156.508095 L272.288296,155.876786 C272.023546,153.586256 271.721204,151.563014 271.374753,149.817202 L271.31,149.5 L285.5,149.499993 L285.5,147.500003 L270.844,147.499 L270.703903,146.984954 C269.807071,143.847346 268.677861,142.123708 267.122157,142.070294 L266.958981,142.085049 C265.397176,142.279275 264.28465,143.967156 263.452266,146.924221 L263.297,147.499 L249,147.500011 L249,149.500018 L262.855,149.499 L262.789941,149.847955 C262.371922,152.130806 262.056065,154.869221 261.832914,157.991281 L261.742926,159.352585 L261.576301,162.746386 L261.532508,164.018969 C261.479489,165.727378 261.447801,167.480525 261.435562,169.256932 L261.43,171.087 L225.73,170.352 L225.73,162.793 L225.732387,162.45855 L225.728504,162.135369 C225.62493,157.300719 223.493135,153.073733 220.821992,152.098319 L220.698,152.057 L220.612998,118.178729 L220.508818,116.892426 L219.954929,111.333489 L219.804421,110.116146 C218.356887,98.8948091 215.565198,90.8783223 210.211105,84.6892124 L209.799248,84.2218816 L209.537,84.143 L209.508434,83.8836185 L209.394385,82.7504153 L209.29002,82.24061 L209.077524,81.2438488 C209.041688,81.0802612 209.005642,80.9179435 208.969384,80.7568958 L208.749303,79.8058531 C208.637991,79.3379542 208.524767,78.8814908 208.409615,78.4364696 L208.176732,77.5616858 C205.97905,69.5394677 203.104947,65.5058613 199.437256,65.5058613 Z";
	input = @"M199.437256,65.5058613 C196.053656,65.5058613 193.580837,68.68756 191.938802,74.9733731 L190.429355,82.5334119 L190.049757,83.3326069 C184.134539,89.9722577 181.136446,99.1626952 179.672508,112.23174 L179.14267,117.861164 L178.949678,152.079099 L178.766649,152.151758 C176.035332,153.315972 173.950713,157.803511 174.035072,162.785465 L174.035,170.338 L10.9346859,173.703106 C6.78223247,174.112055 5.1487124,178.576411 5.52899469,185.099876 C6.53163501,192.666127 7.8405963,197.576658 9.45587855,199.831469 C10.2550454,200.745823 10.8267525,201.203 11.171,201.203 L142.642437,218.335814 L173.781,217.921 L178.859,226.123 L178.831,237.441 L121.098,303.158873 L121.098,318.166121 L185.075562,286.533725 C202.894747,286.436482 212.735348,286.409529 214.597366,286.452865 L278.656,318.096226 L278.656,303.111741 L220.894,226.84 L227.079,217.952 L258.165207,218.374954 L389.888614,201.210807 L391.031318,200.634446 C393.06327,198.115151 394.497316,192.948058 395.333454,185.133167 C395.710146,178.534885 394.079224,174.143089 389.979351,173.736441 L225.73,170.352 L225.728504,162.135369 C225.62493,157.300719 223.493135,153.073733 220.821992,152.098319 L220.698,152.057 L220.612998,118.178729 L219.804421,110.116146 C218.356887,98.8948091 215.565198,90.8783223 210.211105,84.6892124 L209.508434,83.8836185 L207.476597,74.9733731 C205.278915,66.951155 203.104947,65.5058613 199.437256,65.5058613 Z";
	NSScanner *scanner = [NSScanner scannerWithString:input];
	scanner.locale = [NSLocale localeWithLocaleIdentifier:@"en_US_POSIX"];
	
	NSCharacterSet *lettersSet = [NSCharacterSet letterCharacterSet];
	NSCharacterSet *numbersSet = [NSCharacterSet characterSetWithCharactersInString:@"0123456789.-"];
	NSCharacterSet *sepSet = [NSCharacterSet characterSetWithCharactersInString:@", "];
	
	NSMutableArray *parsedCommands = [NSMutableArray array];
	
	while (![scanner isAtEnd]) {
		// Read the command letter (e.g., 'M', 'L')
		NSString *command = nil;
		if ([scanner scanCharactersFromSet:[NSCharacterSet letterCharacterSet] intoString:&command]) {
			NSMutableArray *points = [NSMutableArray array];
			
			while (![scanner isAtEnd]) {
				// Try to scan the X value
				float x = 0.0, y = 0.0;
				if ([scanner scanFloat:&x]) {
					// Skip the comma
					if ([scanner scanString:@"," intoString:NULL]) {
						// Try to scan the Y value
						if ([scanner scanFloat:&y]) {
							[points addObject:@[@(x), @(y)]];
						} else {
							NSLog(@"Failed to scan 'y' after x = %f at position %lu", x, (unsigned long)[scanner scanLocation]);
							break;
						}
					} else {
						NSLog(@"Failed to find a comma after x = %f at position %lu", x, (unsigned long)[scanner scanLocation]);
						break;
					}
				} else {
					NSLog(@"Failed to scan 'x' at position %lu", (unsigned long)[scanner scanLocation]);
					break;
				}
			}
			
			[parsedCommands addObject:@{@"command": command, @"points": points}];
		}
	}

	CGMutablePathRef pth;
	
	pth = CGPathCreateMutable();

	// Print parsed results
	for (NSDictionary *command in parsedCommands) {
		NSLog(@"Command: %@, Points: %@", command[@"command"], command[@"points"]);
		if ([command[@"command"] isEqualToString:@"M"]) {
			NSArray *a = command[@"points"];
			NSArray *b = a[0];
			CGFloat x = [b[0] floatValue];
			CGFloat y = [b[1] floatValue];
			CGPathMoveToPoint(pth, NULL, x, y);
		}
		else if ([command[@"command"] isEqualToString:@"L"]) {
			NSArray *a = command[@"points"];
			NSArray *b = a[0];
			CGFloat x = [b[0] floatValue];
			CGFloat y = [b[1] floatValue];
			CGPathAddLineToPoint(pth, NULL, x, y);
		}
		else if ([command[@"command"] isEqualToString:@"C"]) {
			NSArray *a = command[@"points"];
			NSArray *b = a[0];
			CGFloat x1 = [a[0][0] floatValue];
			CGFloat y1 = [a[0][1] floatValue];
			CGFloat x2 = [a[1][0] floatValue];
			CGFloat y2 = [a[1][1] floatValue];
			CGFloat x3 = [a[2][0] floatValue];
			CGFloat y3 = [a[2][1] floatValue];
			CGPathAddCurveToPoint(pth, NULL, x1, y1, x2, y2, x3, y3);
		}
		else if ([command[@"command"] isEqualToString:@"Z"]) {
			CGPathCloseSubpath(pth);
		}
	}

	// Get the bounding box of the path
	CGRect boundingBox = CGPathGetBoundingBox(pth);
	
	// Flip the path on the Y-axis
	//CGPathRef flippedPath = FlipCGPathOnYAxis(pth, boundingBox);
	CGPathRef flippedPath = [self flipCGPathOnYAxis:pth boundingBox:boundingBox];

	
//	pth = CGPathCreateMutable();
//	CGPathMoveToPoint(pth, NULL, 268, 100);
//	//CGPathAddCurveToPoint(pth, NULL, 268, 100, 316, 167, 413, 301);
//	CGPathAddCurveToPoint(pth, NULL, 413, 301, 316, 167, 268, 100);
//	CGPathAddLineToPoint(pth, NULL, 611, 301);
//	//CGPathAddCurveToPoint(pth, NULL, 678, 30, 674, 379, 611, 378);

	CAShapeLayer *c = [CAShapeLayer new];
	c.strokeColor = NSColor.redColor.CGColor;
	c.fillColor = NSColor.yellowColor.CGColor;
	c.path = flippedPath;
	c.path = pth;
	[self.view.layer addSublayer:c];
	//c.position = CGPointMake(100, 100);
	
	NSLog(@"p: %@", [NSValue valueWithRect:CGPathGetBoundingBox(pth)]);
	NSLog(@"f: %@", [NSValue valueWithRect:CGPathGetBoundingBox(flippedPath)]);
	
	CGPathRelease(flippedPath);
	CGPathRelease(pth);
	//[self.view.layer setGeometryFlipped:YES];
}

- (CGPathRef)flipCGPathOnYAxis:(CGPathRef) path boundingBox:(CGRect)boundingBox
{
//CGPathRef FlipCGPathOnYAxis(CGPathRef path, CGRect boundingBox) {
	if (!path) return NULL;
	
	// Calculate the transform matrix
	CGAffineTransform transform = CGAffineTransformIdentity;
	transform = CGAffineTransformTranslate(transform, 0, boundingBox.size.height);
	transform = CGAffineTransformScale(transform, 1.0, -1.0);
	
	// Create a mutable copy of the path and apply the transform
	CGMutablePathRef flippedPath = CGPathCreateMutable();
	CGPathAddPath(flippedPath, &transform, path);

	transform = CGAffineTransformIdentity;
	//transform = CGAffineTransformTranslate(transform, -boundingBox.origin.x, boundingBox.origin.y);
	transform = CGAffineTransformTranslate(transform, 0.0, boundingBox.origin.y * 2.0);

	CGMutablePathRef originPath = CGPathCreateMutable();
	CGPathAddPath(originPath, &transform, flippedPath);
	
	CGPathRelease(flippedPath);

	return originPath; // Caller is responsible for releasing this path
}
@end
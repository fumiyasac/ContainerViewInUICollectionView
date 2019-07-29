//
//  BPSigner.m
//  The Blueprint Project
//
//  Created by Hunter Dolan on 5/29/15.
//  Copyright (c) 2015 The Blueprint Project. All rights reserved.
//

#import "BPSigner.h"
#import <CommonCrypto/CommonCrypto.h>
#import "tommath.h"

@implementation BPSigner


+(NSString *)signString:(NSString *)string withKey:(NSString *)key
{
    // Objective-C is stupid and improrperly escapes forward slashes.
    // Go 'knows how to json' so this breaks our signing system.
    string = [string stringByReplacingOccurrencesOfString:@"\\/" withString:@"/"];
    
    const char *cKey  = [key cStringUsingEncoding:NSUTF8StringEncoding];
    const char *cData = [string cStringUsingEncoding:NSUTF8StringEncoding];
    unsigned char cHMAC[CC_SHA256_DIGEST_LENGTH];
    CCHmac(kCCHmacAlgSHA256, cKey, strlen(cKey), cData, strlen(cData), cHMAC);
    
    NSData *HMACData = [[NSData alloc] initWithBytes:cHMAC length:sizeof(cHMAC)];
    
    const unsigned char *buffer = (const unsigned char *)HMACData.bytes;
    
    NSString *HMAC = [NSMutableString stringWithCapacity:HMACData.length * 2];
    
    for (int i = 0; i < HMACData.length; ++i)
        HMAC = [HMAC stringByAppendingFormat:@"%02lx", (unsigned long)buffer[i]];
    
    NSString *alphabet = @"123456789abcdefghijkmnopqrstuvwxyzABCDEFGHJKLMNPQRSTUVWXYZ";
    
    mp_int m_number;
    mp_init(&m_number);
    mp_read_radix(&m_number, [HMAC cStringUsingEncoding:NSUTF8StringEncoding], 16);
    
    mp_int m_base_count;
    mp_init(&m_base_count);
    mp_set_int(&m_base_count, alphabet.length);
    
    NSString *encoded = @"";
    int cmp = MP_GT;
    while(cmp == MP_GT || cmp == MP_EQ) {
        mp_int m_div;
        mp_init(&m_div);
        mp_div(&m_number, &m_base_count, &m_div, NULL);
        
        mp_int m_mult;
        mp_init(&m_mult);
        mp_mul(&m_div, &m_base_count, &m_mult);
        
        mp_int m_mod;
        mp_init(&m_mod);
        mp_sub(&m_number, &m_mult, &m_mod);
        
        NSString *alphabetChar = [alphabet substringWithRange: NSMakeRange(mp_get_int(&m_mod), 1)];
        encoded = [NSString stringWithFormat: @"%@%@", alphabetChar, encoded];
        m_number = m_div;
        cmp = mp_cmp(&m_number, &m_base_count);
    }
    
    if(mp_get_int(&m_number)) {
        encoded = [NSString stringWithFormat: @"%@%@", [alphabet substringWithRange: NSMakeRange(mp_get_int(&m_number), 1)], encoded];
    }
    
    
    
    return encoded;
}

@end

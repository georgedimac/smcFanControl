/*
 *    FanControl
 *
 *    Copyright (c) 2006-2012 Hendrik Holtmann
 *
 *    Sensor.m - MacBook(Pro) FanControl application
 *
 *    This program is free software; you can redistribute it and/or modify
 *    it under the terms of the GNU General Public License as published by
 *    the Free Software Foundation; either version 2 of the License, or
 *    (at your option) any later version.
 *
 *    This program is distributed in the hope that it will be useful,
 *    but WITHOUT ANY WARRANTY; without even the implied warranty of
 *    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *    GNU General Public License for more details.
 *
 *    You should have received a copy of the GNU General Public License
 *    along with this program; if not, write to the Free Software
 *    Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
 */

#import "IOKitSensor.h"

@implementation IOKitSensor

static BOOL isSOCSensor(CFStringRef sensorName) {
    return CFStringHasPrefix(sensorName, CFSTR("PMGR"));
}

static float toOneDecimalPlace(float value) {
    return roundf(10.0f * value) / 10.0f;
}

+ (float) getSOCTemperature {
    
    IOHIDEventSystemClientRef eventSystemClient = IOHIDEventSystemClientCreate(kCFAllocatorDefault);
    CFArrayRef services = IOHIDEventSystemClientCopyServices(eventSystemClient);
    if (services) {
        
        float socSensorSum = 0.0f;
        int socSensorCount = 0;
        
        for (int i = 0; i < CFArrayGetCount(services); i++) {
            IOHIDServiceClientRef serviceClientRef = (IOHIDServiceClientRef)CFArrayGetValueAtIndex(services, i);
            CFStringRef sensorName = IOHIDServiceClientCopyProperty(serviceClientRef, CFSTR("Product"));
            if (sensorName) {
                if (isSOCSensor(sensorName)) {
                    IOHIDEventRef event = IOHIDServiceClientCopyEvent(serviceClientRef, kIOHIDEventTypeTemperature, 0, 0);
                    if (event) {
                        IOHIDFloat sensorTemperature = IOHIDEventGetFloatValue(event, IOHIDEventFieldBase(kIOHIDEventTypeTemperature));
                        CFRelease(event);
                        socSensorSum += sensorTemperature;
                        socSensorCount++;
                    }
                }
                CFRelease(sensorName);
            }
        }
        
        CFRelease(services);
        CFRelease(eventSystemClient);
        
        float avgSOCTemp = socSensorCount > 0 ? socSensorSum / socSensorCount: 0.0f;
        return toOneDecimalPlace(avgSOCTemp);
    }
    
    return 0.0f;
}

@end

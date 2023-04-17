/*
 * Copyright 2023 Google LLC
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

#import "FIRAggregateField.h"
#import "FIRAggregateField+Internal.h"
#import "FIRFieldPath+Internal.h"

using firebase::firestore::model::AggregateField;
using firebase::firestore::model::AggregateAlias;

NS_ASSUME_NONNULL_BEGIN

#pragma mark - FIRAggregateField

@interface FIRAggregateField ()
@property(nonatomic, strong, readwrite) FIRFieldPath *_fieldPath;
@end

@implementation FIRAggregateField
- (instancetype)initWithFieldPath:(FIRFieldPath *)fieldPath {
  if (self = [super init]) {
    self._fieldPath = fieldPath;
  }
  return self;
}

- (instancetype)initPrivate {
  if (self = [super init]) {
  }
  return self;
}

- (AggregateField)createInternalValue {
  HARD_FAIL("Use createInternalValue from FIRAggregateField sub class.");
  return AggregateField();
}

- (AggregateAlias)createAlias {
  HARD_FAIL("Use createAlias from FIRAggregateField sub class.");
  return AggregateAlias(std::string{});
}

- (const std::string)name {
  HARD_FAIL("Use name from FIRAggregateField sub class.");
  return std::string{};
}

+ (instancetype)aggregateFieldForCount NS_SWIFT_NAME(count()) {
  return [[FSTCountAggregateField alloc] initPrivate];
}

+ (instancetype)aggregateFieldForSumOfField:(NSString *)field NS_SWIFT_NAME(sum(_:)) {
  FIRFieldPath *fieldPath = [FIRFieldPath pathWithDotSeparatedString:field];
  FSTSumAggregateField *af = [[FSTSumAggregateField alloc] initWithFieldPath:fieldPath];
  return af;
}

+ (instancetype)aggregateFieldForSumOfFieldPath:(FIRFieldPath *)fieldPath NS_SWIFT_NAME(sum(_:)) {
  return [[FSTSumAggregateField alloc] initWithFieldPath:fieldPath];
}

+ (instancetype)aggregateFieldForAverageOfField:(NSString *)field NS_SWIFT_NAME(average(_:)) {
  FIRFieldPath *fieldPath = [FIRFieldPath pathWithDotSeparatedString:field];
  FSTAverageAggregateField *af = [[FSTAverageAggregateField alloc] initWithFieldPath:fieldPath];
  return af;
}

+ (instancetype)aggregateFieldForAverageOfFieldPath:(FIRFieldPath *)fieldPath
    NS_SWIFT_NAME(average(_:)) {
  return [[FSTAverageAggregateField alloc] initWithFieldPath:fieldPath];
}

@end

#pragma mark - FSTSumAggregateField
@implementation FSTSumAggregateField
- (instancetype)initWithFieldPath:(FIRFieldPath *)fieldPath {
  self = [super initWithFieldPath:fieldPath];
  return self;
}

- (AggregateAlias)createAlias {
  return AggregateAlias([self name] + std::string{"_"} +
                               super._fieldPath.internalValue.CanonicalString());
}

- (AggregateField)createInternalValue {
  return AggregateField([self name], [self createAlias], super._fieldPath.internalValue);
}

- (const std::string)name {
  return AggregateField::kOpSum;
}

@end

#pragma mark - FSTAverageAggregateField

@implementation FSTAverageAggregateField
- (instancetype)initWithFieldPath:(FIRFieldPath *)fieldPath {
  self = [super initWithFieldPath:fieldPath];
  return self;
}

- (AggregateAlias)createAlias {
  return AggregateAlias([self name] + std::string{"_"} +
                               super._fieldPath.internalValue.CanonicalString());
}

- (AggregateField)createInternalValue {
  return AggregateField([self name], [self createAlias], super._fieldPath.internalValue);
}

- (const std::string)name {
  return AggregateField::kOpAvg;
}

@end

#pragma mark - FSTCountAggregateField

@implementation FSTCountAggregateField
- (instancetype)initPrivate {
  return [super initPrivate];
}

- (AggregateAlias)createAlias {
  return AggregateAlias([self name]);
}

- (AggregateField)createInternalValue {
  return AggregateField([self name], [self createAlias]);
}

- (const std::string)name {
  return AggregateField::kOpCount;
}

@end

NS_ASSUME_NONNULL_END
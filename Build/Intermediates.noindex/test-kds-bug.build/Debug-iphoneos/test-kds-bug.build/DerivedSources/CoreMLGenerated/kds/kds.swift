//
// kds.swift
//
// This file was automatically generated and should not be edited.
//

import CoreML


/// Model Prediction Input Type
@available(OSX 13.0, iOS 11.0, tvOS 11.0, watchOS 4.0, *)
class kdsInput : MLFeatureProvider {

    /// Audio input as 26 element vector of doubles
    var input1: MLMultiArray
    
    var featureNames: Set<String> {
        get {
            return ["input1"]
        }
    }
    
    func featureValue(for featureName: String) -> MLFeatureValue? {
        if (featureName == "input1") {
            return MLFeatureValue(multiArray: input1)
        }
        return nil
    }
    
    init(input1: MLMultiArray) {
        self.input1 = input1
    }
}


/// Model Prediction Output Type
@available(OSX 13.0, iOS 11.0, tvOS 11.0, watchOS 4.0, *)
class kdsOutput : MLFeatureProvider {

    /// Audio transcription as 29 element vector of doubles
    let output1: MLMultiArray
    
    var featureNames: Set<String> {
        get {
            return ["output1"]
        }
    }
    
    func featureValue(for featureName: String) -> MLFeatureValue? {
        if (featureName == "output1") {
            return MLFeatureValue(multiArray: output1)
        }
        return nil
    }
    
    init(output1: MLMultiArray) {
        self.output1 = output1
    }
}


/// Class for model loading and prediction
@available(OSX 13.0, iOS 11.0, tvOS 11.0, watchOS 4.0, *)
class kds {
    var model: MLModel

    /**
        Construct a model with explicit path to mlmodel file
        - parameters:
           - url: the file url of the model
           - throws: an NSError object that describes the problem
    */
    init(contentsOf url: URL) throws {
        self.model = try MLModel(contentsOf: url)
    }

    /// Construct a model that automatically loads the model from the app's bundle
    convenience init() {
        let bundle = Bundle(for: kds.self)
        let assetPath = bundle.url(forResource: "kds", withExtension:"mlmodelc")
        try! self.init(contentsOf: assetPath!)
    }

    /**
        Make a prediction using the structured interface
        - parameters:
           - input: the input to the prediction as kdsInput
        - throws: an NSError object that describes the problem
        - returns: the result of the prediction as kdsOutput
    */
    func prediction(input: kdsInput) throws -> kdsOutput {
        let outFeatures = try model.prediction(from: input)
        let result = kdsOutput(output1: outFeatures.featureValue(for: "output1")!.multiArrayValue!)
        return result
    }

    /**
        Make a prediction using the convenience interface
        - parameters:
            - input1: Audio input as 26 element vector of doubles
        - throws: an NSError object that describes the problem
        - returns: the result of the prediction as kdsOutput
    */
    func prediction(input1: MLMultiArray) throws -> kdsOutput {
        let input_ = kdsInput(input1: input1)
        return try self.prediction(input: input_)
    }
}

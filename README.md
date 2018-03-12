# kDS2iOS


This is a Speech Recognition iOS App that makes use of the CoreML model created in Keras from ![github.com/robmsmt/KerasDeepSpeech](https://github.com/robmsmt/KerasDeepSpeech)


## Example Image
![](https://github.com/robmsmt/kDS2iOS/raw/master/kDS2iOS/new/interface.png)



## Issues
 1. Issue with Core ML tools and the conversion of Keras RNNs with return_sequences=True which is a requirement for ASR to work with DS models. Update- this is [supposedly fixed](https://forums.developer.apple.com/thread/85737). I have tested a simple RNN and it appears to work with simple NN. I will update this repo when i've built this.
 
 

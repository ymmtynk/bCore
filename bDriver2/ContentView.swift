//
//  ContentView.swift
//  bDriver2
//
//  Created by OfCourseIStillLoveYou on 2022/03/27.
//

import SwiftUI
import GameController



struct ContentView: View {
  
  @EnvironmentObject var bDriver : bCoreDriver
  
  @State var mot1SettingHide : Bool = true
  @State var mot2SettingHide : Bool = true
  @State var srv1SettingHide : Bool = true
  @State var srv2SettingHide : Bool = true
  @State var srv3SettingHide : Bool = true
  @State var srv4SettingHide : Bool = true
  @State var nameSettingHide : Bool = true
  
  @State var gcSettingHide   : Bool = true
  
  @State var debugInfoHide   : Bool = true

  //@State var newName : String = ""
  
  @State var posX : CGFloat = 0
  @State var posY : CGFloat = 0

  //@State var posMXSX : CGFloat = 0
  @State var posMXTY : CGFloat = 0

  
  init(){
    //List全体の背景色の設定
    UITableView.appearance().backgroundColor = UIColor.clear
  }
  
  
  var body: some View {
    //   Text("Hello, world!")
    //       .padding()
    
    //
    //
    //
    
    GeometryReader { bodyView in
    
      ZStack {
        
        //
        // main control view
        //
        VStack(spacing: 0) {
          //
          // Button for BLEd Connect/Disconnect
          // Battery Info
          //
          HStack(spacing: 0) {
            // ID
            Text(String(self.bDriver.connectionStatus))
            .foregroundColor(self.bDriver.connectionColor)
            .padding(.horizontal)
            .lineLimit(1)
            .minimumScaleFactor(0.5)
            .frame(alignment: .leading)
            .onTapGesture(count: 3) {
              print("Name Setting On!")
              self.bDriver.newName = self.bDriver.config.name
              self.nameSettingHide = false
            }
            
            Spacer()
            
            // Game Controller
            Text(String(self.bDriver.gameControllerString))
            .lineLimit(1)
            .minimumScaleFactor(0.5)
            .frame(width: bodyView.size.width/3, alignment: .center)
            .hidden(self.$bDriver.gameControllerHide)
            .onTapGesture(count: 3) {
              print("GC Setting On!")
              self.gcSettingHide = false
            }
 
            Spacer()
            
            // Battery
            Text(String(self.bDriver.infoBatteryString))
            .foregroundColor(self.bDriver.infoBatteryColor)
            //.foregroundColor(.red)
            .padding(.horizontal)
            .lineLimit(1)
            .minimumScaleFactor(0.5)
            .frame(width: bodyView.size.width/6, alignment: .leading)
          }
          .frame(width: bodyView.size.width, height: bodyView.size.height/20)
          .background(Color.gray)
          .onTapGesture(count: 8) {
            print("Debug Info On/Off")
            self.debugInfoHide.toggle()
          }
          
          //
          // LED Button
          //
          HStack(spacing: 0) {
            Spacer()
            //Divider()
            
            // LED
            Button(action: {self.bDriver.buttonLED1Action() }) {
              Text("LED1")
              .padding(.horizontal)
              .background(self.bDriver.buttonColorLED1)
              .foregroundColor(Color.black)
              //.cornerRadius(10)
              .overlay(RoundedRectangle(cornerRadius: 0).stroke(Color.black, lineWidth:1))
              .hidden(self.$bDriver.led1LabelHide)
            }
            //.disabled(self.bDriver.gameControllerConnected)
            
            Spacer()
            
            Button(action: {self.bDriver.buttonLED2Action() }) {
              Text("LED2")
              .padding(.horizontal)
              .background(self.bDriver.buttonColorLED2)
              .foregroundColor(Color.black)
              //.cornerRadius(10)
              .overlay(RoundedRectangle(cornerRadius: 0).stroke(Color.black, lineWidth:1))
              .hidden(self.$bDriver.led2LabelHide)
            }
            //.disabled(self.bDriver.gameControllerConnected)
            
            Spacer()
            
            Button(action: {self.bDriver.buttonLED3Action() }) {
              Text("LED3")
              .padding(.horizontal)
              .background(self.bDriver.buttonColorLED3)
              .foregroundColor(Color.black)
              //.cornerRadius(10)
              .overlay(RoundedRectangle(cornerRadius: 0).stroke(Color.black, lineWidth:1))
              .hidden(self.$bDriver.led3LabelHide)
            }
            //.disabled(self.bDriver.gameControllerConnected)

            Spacer()
            
            Button(action: {self.bDriver.buttonLED4Action() }) {
              Text("LED4")
              .padding(.horizontal)
              .background(self.bDriver.buttonColorLED4)
              .foregroundColor(Color.black)
              //.cornerRadius(10)
              .overlay(RoundedRectangle(cornerRadius: 0).stroke(Color.black, lineWidth:1))
              .hidden(self.$bDriver.led4LabelHide)
            }
            //.disabled(self.bDriver.gameControllerConnected)

            Spacer()
            
          } // HStack LED Button
          .frame(width: bodyView.size.width, height: bodyView.size.height/20*3)
          .background(Color.gray)
          
          
          
          ZStack() {
            
            //
            // Slider V6
            //
            VStack(spacing: 0) {
              
              //
              // Virtical Slider x 6
              //
              HStack(spacing: 0) {
                
                VStack(spacing: 0) {
                  SwiftUISpringSlider(trackColor: .blue, value: self.$bDriver.sliderValueMot1)
                  .frame(width: bodyView.size.height - (bodyView.size.height/20*6), height: bodyView.size.width*3/14)
                  .rotationEffect(.degrees(-90.0), anchor: .center)
                  .hidden(self.$bDriver.config.mot1Hide)
                  .hidden(self.$bDriver.mot1LabelHide)
                  .disabled(self.bDriver.gameControllerConnected)
                  .id(!self.bDriver.gameControllerConnected)
                }
                .frame(width: bodyView.size.width*3/14, height: bodyView.size.height - (bodyView.size.height/20*3))
                
                VStack(spacing: 0) {
                  SwiftUISyncSlider(trackColor: .yellow, value: self.$bDriver.sliderValueSrv1,
                    sync2: self.$bDriver.config.srv2Sync,  sync3: self.$bDriver.config.srv3Sync,  sync4: self.$bDriver.config.srv4Sync,
                    value2: self.$bDriver.sliderValueSrv2, value3: self.$bDriver.sliderValueSrv3, value4: self.$bDriver.sliderValueSrv4
                  )
                  .frame(width: bodyView.size.height - (bodyView.size.height/20*6), height: bodyView.size.width/7)
                  .rotationEffect(.degrees(-90.0), anchor: .center)
                  .hidden(self.$bDriver.config.srv1Hide)
                  .hidden(self.$bDriver.srv1LabelHide)
                  .disabled(self.bDriver.gameControllerConnected)
                  .id(!self.bDriver.gameControllerConnected)
                  .disabled(self.$bDriver.config.srv1Motion.wrappedValue != 1)
                  .id(self.$bDriver.config.srv1Motion.wrappedValue)
                }
                .frame(width: bodyView.size.width/7, height: bodyView.size.height - (bodyView.size.height/20*3))
                
                VStack(spacing: 0) {
                  SwiftUINormalSlider(trackColor: .yellow, value: self.$bDriver.sliderValueSrv2)
                  .frame(width: bodyView.size.height - (bodyView.size.height/20*6), height: bodyView.size.width/7)
                  .rotationEffect(.degrees(-90.0), anchor: .center)
                  .hidden(self.$bDriver.config.srv2Hide)
                  .hidden(self.$bDriver.srv2LabelHide)
                  .disabled(self.bDriver.config.srv2Sync)
                  .id(!self.bDriver.config.srv2Sync)
                  .disabled(self.bDriver.gameControllerConnected)
                  .id(!self.bDriver.gameControllerConnected)
                  .disabled(self.$bDriver.config.srv2Motion.wrappedValue != 1)
                  .id(self.$bDriver.config.srv2Motion.wrappedValue)
                }
                .frame(width: bodyView.size.width/7, height: bodyView.size.height - (bodyView.size.height/20*3))
                
                VStack(spacing: 0) {
                  SwiftUINormalSlider(trackColor: .yellow, value: self.$bDriver.sliderValueSrv3)
                  .frame(width: bodyView.size.height - (bodyView.size.height/20*6), height: bodyView.size.width/7)
                  .rotationEffect(.degrees(-90.0), anchor: .center)
                  .hidden(self.$bDriver.config.srv3Hide)
                  .hidden(self.$bDriver.srv3LabelHide)
                  .disabled(self.bDriver.config.srv3Sync)
                  .id(!self.bDriver.config.srv3Sync)
                  .disabled(self.bDriver.gameControllerConnected)
                  .id(!self.bDriver.gameControllerConnected)
                  .disabled(self.$bDriver.config.srv3Motion.wrappedValue != 1)
                  .id(self.$bDriver.config.srv3Motion.wrappedValue)
                }
                .frame(width: bodyView.size.width/7, height: bodyView.size.height - (bodyView.size.height/20*3))
                
                VStack(spacing: 0) {
                  SwiftUINormalSlider(trackColor: .yellow, value: self.$bDriver.sliderValueSrv4)
                  .frame(width: bodyView.size.height - (bodyView.size.height/20*6), height: bodyView.size.width/7)
                  .rotationEffect(.degrees(-90.0), anchor: .center)
                  .hidden(self.$bDriver.config.srv4Hide)
                  .hidden(self.$bDriver.srv4LabelHide)
                  .disabled(self.bDriver.config.srv4Sync)
                  .id(!self.bDriver.config.srv4Sync)
                  .disabled(self.bDriver.gameControllerConnected)
                  .id(!self.bDriver.gameControllerConnected)
                  .disabled(self.$bDriver.config.srv4Motion.wrappedValue != 1)
                  .id(self.$bDriver.config.srv4Motion.wrappedValue)
                }
                .frame(width: bodyView.size.width/7, height: bodyView.size.height - (bodyView.size.height/20*3))
                
                VStack(spacing: 0) {
                  SwiftUISpringSlider(trackColor: .blue, value: self.$bDriver.sliderValueMot2)
                  .frame(width: bodyView.size.height - (bodyView.size.height/20*6), height: bodyView.size.width*3/14)
                  .rotationEffect(.degrees(-90.0), anchor: .center)
                  .hidden(self.$bDriver.config.mot2Hide)
                  .hidden(self.$bDriver.mot2LabelHide)
                  .disabled(self.bDriver.gameControllerConnected)
                  .id(!self.bDriver.gameControllerConnected)
                }
                .frame(width: bodyView.size.width*3/14, height: bodyView.size.height - (bodyView.size.height/20*3))
                
              } // HStack for 6 V-Slider
              .frame(width: bodyView.size.width, height: bodyView.size.height - (bodyView.size.height/20*5))
              
              //
              // Slider Label x 6 (Triple tap to enter setting)
              //
              HStack(spacing: 0) {
                
                VStack(spacing: 0) {
                  Text("Mot1")
                  .hidden(self.$bDriver.mot1LabelHide)
                  .onTapGesture(count: 3) { print("Mot1 Setting On!"); self.mot1SettingHide = false }
                }
                .frame(width: bodyView.size.width*3/14)
                
                VStack(spacing: 0) {
                  Text("Srv1")
                  .hidden(self.$bDriver.srv1LabelHide)
                  .onTapGesture(count: 3) { print("Srv1 Setting On!"); self.srv1SettingHide = false }
                }
                .frame(width: bodyView.size.width/7)
                
                VStack(spacing: 0) {
                  Text("Srv2")
                  .hidden(self.$bDriver.srv2LabelHide)
                  .onTapGesture(count: 3) { print("Srv2 Setting On!"); self.srv2SettingHide = false }
                }
                .frame(width: bodyView.size.width/7)
                
                VStack(spacing: 0) {
                  Text("Srv3")
                  .hidden(self.$bDriver.srv3LabelHide)
                  .onTapGesture(count: 3) { print("Srv3 Setting On!"); self.srv3SettingHide = false }
                }
                .frame(width: bodyView.size.width/7)
                
                VStack(spacing: 0) {
                  Text("Srv4")
                  .hidden(self.$bDriver.srv4LabelHide)
                  .onTapGesture(count: 3) { print("Srv4 Setting On!"); self.srv4SettingHide = false }
                }
                .frame(width: bodyView.size.width/7)
                
                VStack(spacing: 0) {
                  Text("Mot2")
                  .hidden(self.$bDriver.mot2LabelHide)
                  .onTapGesture(count: 3) { print("Mot2 Setting On!"); self.mot2SettingHide = false }
                }
                .frame(width: bodyView.size.width*3/14)
                
              }
              .frame(width: bodyView.size.width, height: bodyView.size.height/20)
              .background(Color.gray)
              
            } // VStack
            .background(Color.gray)
            .frame(width: bodyView.size.width, height: bodyView.size.height*16/20)
            .hidden(self.$bDriver.style1Hide)
            //
            // Style V6
            //
            
            //
            // Style MVSH
            //
            VStack(spacing: 0) {
              HStack(spacing: 0) {
                
                // Mot1
                VStack(spacing: 0) {
                  VStack(spacing: 0) {
                    // Mot1 V-Slider
                    SwiftUISpringSlider(trackColor: .blue, value: self.$bDriver.sliderValueMot1)
                    .frame(width: bodyView.size.height*12/20)
                    .rotationEffect(.degrees(-90.0), anchor: .center)
                    .hidden(self.$bDriver.config.mot1Hide)
                    .hidden(self.$bDriver.mot1LabelHide)
                    .disabled(self.bDriver.gameControllerConnected)
                    .id(!self.bDriver.gameControllerConnected)
                  }
                  //.border(Color.red, width: 3)
                  .frame(height: bodyView.size.height*15/20)
                  
                  VStack(spacing: 0) {
                    Text("Mot1")
                    .hidden(self.$bDriver.mot1LabelHide)
                    .onTapGesture(count: 3) { print("Mot1 Setting On!"); self.mot1SettingHide = false }
                  }
                  //.border(Color.yellow, width: 3)
                  .frame(height: bodyView.size.height/20)
                }
                //.border(Color.green, width: 1)
                .frame(width: bodyView.size.width/8, height: bodyView.size.height*16/20)
                
                // Servo 1,2
                VStack(spacing: 0) {
                  // Servo1
                  VStack(spacing: 0) {
                    VStack(spacing: 0) {
                      Text("Srv1")
                      .hidden(self.$bDriver.srv1LabelHide)
                      .onTapGesture(count: 3) { print("Srv1 Setting On!"); self.srv1SettingHide = false }
                    }
                    //.border(Color.yellow, width: 1)
                    .frame(height: bodyView.size.height/20)
                    
                    VStack(spacing: 0) {
                      SwiftUISyncSlider(trackColor: .yellow, value: self.$bDriver.sliderValueSrv1,
                        sync2: self.$bDriver.config.srv2Sync,  sync3: self.$bDriver.config.srv3Sync,  sync4: self.$bDriver.config.srv4Sync,
                        value2: self.$bDriver.sliderValueSrv2, value3: self.$bDriver.sliderValueSrv3, value4: self.$bDriver.sliderValueSrv4
                      )
                      .frame(width: bodyView.size.width/3/*, height: bodyView.size.height*6/20*/)
                      .hidden(self.$bDriver.config.srv1Hide)
                      .hidden(self.$bDriver.srv1LabelHide)
                      .disabled(self.bDriver.gameControllerConnected)
                      .id(!self.bDriver.gameControllerConnected)
                      .disabled(self.$bDriver.config.srv1Motion.wrappedValue != 1)
                      .id(self.$bDriver.config.srv1Motion.wrappedValue)
                    }
                    //.border(Color.red, width: 1)
                    .frame(height: bodyView.size.height*7/20)
                  }
                  //.border(Color.yellow, width: 1)
                  
                  // Servo2
                  VStack(spacing: 0) {
                    VStack(spacing: 0) {
                      SwiftUINormalSlider(trackColor: .yellow, value: self.$bDriver.sliderValueSrv2)
                      .frame(width: bodyView.size.width/3/*, height: bodyView.size.height*6/20*/)
                      .hidden(self.$bDriver.config.srv2Hide)
                      .hidden(self.$bDriver.srv2LabelHide)
                      .disabled(self.bDriver.config.srv2Sync)
                      .id(!self.bDriver.config.srv2Sync)
                      .disabled(self.bDriver.gameControllerConnected)
                      .id(!self.bDriver.gameControllerConnected)
                      .disabled(self.$bDriver.config.srv2Motion.wrappedValue != 1)
                      .id(self.$bDriver.config.srv2Motion.wrappedValue)
                    }
                    //.border(Color.red, width: 1)
                    .frame(height: bodyView.size.height*7/20)
                    
                    VStack(spacing: 0) {
                      Text("Srv2")
                      .hidden(self.$bDriver.srv2LabelHide)
                      .onTapGesture(count: 3) { print("Srv2 Setting On!"); self.srv2SettingHide = false }
                    }
                    //.border(Color.yellow, width: 1)
                    .frame(height: bodyView.size.height/20)
                    
                  }
                  //.border(Color.yellow, width: 1)
                }
                //.border(Color.green, width: 1)
                .frame(width: bodyView.size.width/8*3, height: bodyView.size.height*16/20)
                
                // Servo 3,4
                VStack(spacing: 0) {
                  // Servo3
                  VStack(spacing: 0) {
                    VStack(spacing: 0) {
                      Text("Srv3")
                      .hidden(self.$bDriver.srv3LabelHide)
                      .onTapGesture(count: 3) { print("Srv3 Setting On!"); self.srv3SettingHide = false }
                    }
                    //.border(Color.yellow, width: 1)
                    .frame(height: bodyView.size.height/20)
                    
                    VStack(spacing: 0) {
                      SwiftUINormalSlider(trackColor: .yellow, value: self.$bDriver.sliderValueSrv3)
                      .frame(width: bodyView.size.width/3/*, height: bodyView.size.height*6/20*/)
                      .hidden(self.$bDriver.config.srv3Hide)
                      .hidden(self.$bDriver.srv3LabelHide)
                      .disabled(self.bDriver.config.srv3Sync)
                      .id(!self.bDriver.config.srv3Sync)
                      .disabled(self.bDriver.gameControllerConnected)
                      .id(!self.bDriver.gameControllerConnected)
                      .disabled(self.$bDriver.config.srv3Motion.wrappedValue != 1)
                      .id(self.$bDriver.config.srv3Motion.wrappedValue)
                    }
                    //.border(Color.red, width: 1)
                    .frame(height: bodyView.size.height*7/20)
                  }
                  //.border(Color.yellow, width: 1)
                  
                  // Servo4
                  VStack(spacing: 0) {
                    VStack(spacing: 0) {
                      SwiftUINormalSlider(trackColor: .yellow, value: self.$bDriver.sliderValueSrv4)
                      .frame(width: bodyView.size.width/3/*, height: bodyView.size.height*6/20*/)
                      .hidden(self.$bDriver.config.srv4Hide)
                      .hidden(self.$bDriver.srv4LabelHide)
                      .disabled(self.bDriver.config.srv4Sync)
                      .id(!self.bDriver.config.srv4Sync)
                      .disabled(self.bDriver.gameControllerConnected)
                      .id(!self.bDriver.gameControllerConnected)
                      .disabled(self.$bDriver.config.srv4Motion.wrappedValue != 1)
                      .id(self.$bDriver.config.srv4Motion.wrappedValue)
                    }
                    //.border(Color.red, width: 1)
                    .frame(height: bodyView.size.height*7/20)
                    
                    VStack(spacing: 0) {
                      Text("Srv4")
                      .hidden(self.$bDriver.srv4LabelHide)
                      .onTapGesture(count: 3) { print("Srv4 Setting On!"); self.srv4SettingHide = false }
                    }
                    //.border(Color.yellow, width: 1)
                    .frame(height: bodyView.size.height/20)
                    
                  }
                  //.border(Color.yellow, width: 1)
                }
                //.border(Color.green, width: 1)
                .frame(width: bodyView.size.width/8*3, height: bodyView.size.height*16/20)
                
                // Mot2
                VStack(spacing: 0) {
                  VStack(spacing: 0) {
                    // Mot2 V-Slider
                    SwiftUISpringSlider(trackColor: .blue, value: self.$bDriver.sliderValueMot2)
                    .frame(width: bodyView.size.height*12/20)
                    .rotationEffect(.degrees(-90.0), anchor: .center)
                    .hidden(self.$bDriver.config.mot2Hide)
                    .hidden(self.$bDriver.mot2LabelHide)
                    .disabled(self.bDriver.gameControllerConnected)
                    .id(!self.bDriver.gameControllerConnected)
                  }
                  //.border(Color.red, width: 3)
                  .frame(height: bodyView.size.height*15/20)
                  
                  VStack(spacing: 0) {
                    Text("Mot2")
                    .hidden(self.$bDriver.mot2LabelHide)
                    .onTapGesture(count: 3) { print("Mot2 Setting On!"); self.mot2SettingHide = false }
                  }
                  //.border(Color.yellow, width: 3)
                  .frame(height: bodyView.size.height/20)
                }
                //.border(Color.green, width: 1)
                .frame(width: bodyView.size.width/8, height: bodyView.size.height*16/20)
              }
              //.border(Color.blue, width: 3)
            }
            .background(Color.gray)
            //.border(Color.red, width: 3)
            .frame(width: bodyView.size.width, height: bodyView.size.height*16/20)
            .hidden(self.$bDriver.style2Hide)
            //
            // Style MVSH
            //

            //
            // StyleH6
            //
            HStack(spacing: 0) {
              
              // Label Srv1,2, Mot1
              VStack(spacing: 0) {
                
                VStack(spacing: 0) {
                  Text("Srv1")
                  .hidden(self.$bDriver.srv1LabelHide)
                  .onTapGesture(count: 3) { print("Srv1 Setting On!"); self.srv1SettingHide = false }
                }
                .frame(height: bodyView.size.height/20*5)
                
                VStack(spacing: 0) {
                  Text("Srv2")
                  .hidden(self.$bDriver.srv2LabelHide)
                  .onTapGesture(count: 3) { print("Srv2 Setting On!"); self.srv2SettingHide = false }
                }
                .frame(height: bodyView.size.height/20*5)
                
                VStack(spacing: 0) {
                  Text("Mot1")
                  .hidden(self.$bDriver.mot1LabelHide)
                  .onTapGesture(count: 3) { print("Mot1 Setting On!"); self.mot1SettingHide = false }
                }
                .frame(height: bodyView.size.height/20*6)
              }
              .frame(width: bodyView.size.width/10)
              
              // Slider Srv1,2, Mot1
              VStack(spacing: 0) {
                
                // Servo1
                VStack(spacing: 0) {
                  SwiftUISyncSlider(trackColor: .yellow, value: self.$bDriver.sliderValueSrv1,
                    sync2: self.$bDriver.config.srv2Sync,  sync3: self.$bDriver.config.srv3Sync,  sync4: self.$bDriver.config.srv4Sync,
                    value2: self.$bDriver.sliderValueSrv2, value3: self.$bDriver.sliderValueSrv3, value4: self.$bDriver.sliderValueSrv4
                  )
                  .frame(width: bodyView.size.width/3/*, height: bodyView.size.height*6/20*/)
                  .hidden(self.$bDriver.config.srv1Hide)
                  .hidden(self.$bDriver.srv1LabelHide)
                  .disabled(self.bDriver.gameControllerConnected)
                  .id(!self.bDriver.gameControllerConnected)
                  .disabled(self.$bDriver.config.srv1Motion.wrappedValue != 1)
                  .id(self.$bDriver.config.srv1Motion.wrappedValue)
                }
                //.border(Color.red, width: 1)
                .frame(height: bodyView.size.height*5/20)
                
                // Servo2
                VStack(spacing: 0) {
                  SwiftUINormalSlider(trackColor: .yellow, value: self.$bDriver.sliderValueSrv2)
                  .frame(width: bodyView.size.width/3/*, height: bodyView.size.height*6/20*/)
                  .hidden(self.$bDriver.config.srv2Hide)
                  .hidden(self.$bDriver.srv2LabelHide)
                  .disabled(self.bDriver.config.srv2Sync)
                  .id(!self.bDriver.config.srv2Sync)
                  .disabled(self.bDriver.gameControllerConnected)
                  .id(!self.bDriver.gameControllerConnected)
                  .disabled(self.$bDriver.config.srv2Motion.wrappedValue != 1)
                  .id(self.$bDriver.config.srv2Motion.wrappedValue)
                }
                //.border(Color.red, width: 1)
                .frame(height: bodyView.size.height*5/20)
                
                // Mot1
                VStack(spacing: 0) {
                  // Mot1 V-Slider
                  SwiftUISpringSlider(trackColor: .blue, value: self.$bDriver.sliderValueMot1)
                  .frame(width: bodyView.size.height*12/20)
                  .hidden(self.$bDriver.config.mot1Hide)
                  .hidden(self.$bDriver.mot1LabelHide)
                  .disabled(self.bDriver.gameControllerConnected)
                  .id(!self.bDriver.gameControllerConnected)
                }
                //.border(Color.red, width: 3)
                .frame(height: bodyView.size.height*6/20)
              }
              .frame(width: bodyView.size.width/10*4)
              
              // Slider Srv3,4, Mot2
              VStack(spacing: 0) {
                
                // Servo3
                VStack(spacing: 0) {
                  SwiftUINormalSlider(trackColor: .yellow, value: self.$bDriver.sliderValueSrv3)
                  .frame(width: bodyView.size.width/3/*, height: bodyView.size.height*6/20*/)
                  .hidden(self.$bDriver.config.srv3Hide)
                  .hidden(self.$bDriver.srv3LabelHide)
                  .disabled(self.bDriver.config.srv3Sync)
                  .id(!self.bDriver.config.srv3Sync)
                  .disabled(self.bDriver.gameControllerConnected)
                  .id(!self.bDriver.gameControllerConnected)
                  .disabled(self.$bDriver.config.srv3Motion.wrappedValue != 1)
                  .id(self.$bDriver.config.srv3Motion.wrappedValue)
                }
                //.border(Color.red, width: 1)
                .frame(height: bodyView.size.height*5/20)
                
                // Servo4
                VStack(spacing: 0) {
                  SwiftUINormalSlider(trackColor: .yellow, value: self.$bDriver.sliderValueSrv4)
                  .frame(width: bodyView.size.width/3/*, height: bodyView.size.height*6/20*/)
                  .hidden(self.$bDriver.config.srv4Hide)
                  .hidden(self.$bDriver.srv4LabelHide)
                  .disabled(self.bDriver.config.srv4Sync)
                  .id(!self.bDriver.config.srv4Sync)
                  .disabled(self.bDriver.gameControllerConnected)
                  .id(!self.bDriver.gameControllerConnected)
                  .disabled(self.$bDriver.config.srv4Motion.wrappedValue != 1)
                  .id(self.$bDriver.config.srv4Motion.wrappedValue)
                }
                //.border(Color.red, width: 1)
                .frame(height: bodyView.size.height*5/20)
                
                // Mot2
                VStack(spacing: 0) {
                  // Mot2 V-Slider
                  SwiftUISpringSlider(trackColor: .blue, value: self.$bDriver.sliderValueMot2)
                  .frame(width: bodyView.size.height*12/20)
                  .hidden(self.$bDriver.config.mot2Hide)
                  .hidden(self.$bDriver.mot2LabelHide)
                  .disabled(self.bDriver.gameControllerConnected)
                  .id(!self.bDriver.gameControllerConnected)
                }
                //.border(Color.red, width: 3)
                .frame(height: bodyView.size.height*6/20)
               }
              .frame(width: bodyView.size.width/10*4)
              
              // Label Srv3,4, Mot2
              VStack(spacing: 0) {
                
                VStack(spacing: 0) {
                  Text("Srv3")
                  .hidden(self.$bDriver.srv3LabelHide)
                  .onTapGesture(count: 3) { print("Srv3 Setting On!"); self.srv3SettingHide = false }
                }
                .frame(height: bodyView.size.height/20*5)
                
                VStack(spacing: 0) {
                  Text("Srv4")
                  .hidden(self.$bDriver.srv4LabelHide)
                  .onTapGesture(count: 3) { print("Srv4 Setting On!"); self.srv4SettingHide = false }
                }
                .frame(height: bodyView.size.height/20*5)
                
                VStack(spacing: 0) {
                  Text("Mot2")
                  .hidden(self.$bDriver.mot2LabelHide)
                  .onTapGesture(count: 3) { print("Mot2 Setting On!"); self.mot2SettingHide = false }
                }
                .frame(height: bodyView.size.height/20*6)
              }
              .frame(width: bodyView.size.width/10)
            }
            .background(Color.gray)
            .frame(width: bodyView.size.width, height: bodyView.size.height*16/20)
            .hidden(self.$bDriver.style3Hide)
            //
            // Style H6ms
            //
            
            //
            // Style H4sX2m
            //
            HStack(spacing: 0) {
              
              // Label Srv1,2,3,4
              VStack(spacing: 0) {
                
                VStack(spacing: 0) {
                  Text("Srv1")
                  .hidden(self.$bDriver.srv1LabelHide)
                  .onTapGesture(count: 3) { print("Srv1 Setting On!"); self.srv1SettingHide = false }
                }
                .frame(height: bodyView.size.height/20*4)
                
                VStack(spacing: 0) {
                  Text("Srv2")
                  .hidden(self.$bDriver.srv2LabelHide)
                  .onTapGesture(count: 3) { print("Srv2 Setting On!"); self.srv2SettingHide = false }
                }
                .frame(height: bodyView.size.height/20*4)
                
                VStack(spacing: 0) {
                  Text("Srv3")
                  .hidden(self.$bDriver.srv3LabelHide)
                  .onTapGesture(count: 3) { print("Srv3 Setting On!"); self.srv3SettingHide = false }
                }
                .frame(height: bodyView.size.height/20*4)
                
                VStack(spacing: 0) {
                  Text("Srv4")
                  .hidden(self.$bDriver.srv2LabelHide)
                  .onTapGesture(count: 3) { print("Srv4 Setting On!"); self.srv4SettingHide = false }
                }
                .frame(height: bodyView.size.height/20*4)
              }
              .frame(width: bodyView.size.width/10)
              
              // Slider Srv1,2,3,4
              VStack(spacing: 0) {
                
                // Servo1
                VStack(spacing: 0) {
                  SwiftUISyncSlider(trackColor: .yellow, value: self.$bDriver.sliderValueSrv1,
                    sync2: self.$bDriver.config.srv2Sync,  sync3: self.$bDriver.config.srv3Sync,  sync4: self.$bDriver.config.srv4Sync,
                    value2: self.$bDriver.sliderValueSrv2, value3: self.$bDriver.sliderValueSrv3, value4: self.$bDriver.sliderValueSrv4
                  )
                  .frame(width: bodyView.size.width/3/*, height: bodyView.size.height*6/20*/)
                  .hidden(self.$bDriver.config.srv1Hide)
                  .hidden(self.$bDriver.srv1LabelHide)
                  .disabled(self.bDriver.gameControllerConnected)
                  .id(!self.bDriver.gameControllerConnected)
                  .disabled(self.$bDriver.config.srv1Motion.wrappedValue != 1)
                  .id(self.$bDriver.config.srv1Motion.wrappedValue)
                }
                //.border(Color.red, width: 1)
                .frame(height: bodyView.size.height*4/20)
                
                // Servo2
                VStack(spacing: 0) {
                  SwiftUINormalSlider(trackColor: .yellow, value: self.$bDriver.sliderValueSrv2)
                  .frame(width: bodyView.size.width/3/*, height: bodyView.size.height*6/20*/)
                  .hidden(self.$bDriver.config.srv2Hide)
                  .hidden(self.$bDriver.srv2LabelHide)
                  .disabled(self.bDriver.config.srv2Sync)
                  .id(!self.bDriver.config.srv2Sync)
                  .disabled(self.bDriver.gameControllerConnected)
                  .id(!self.bDriver.gameControllerConnected)
                  .disabled(self.$bDriver.config.srv2Motion.wrappedValue != 1)
                  .id(self.$bDriver.config.srv2Motion.wrappedValue)
                }
                //.border(Color.red, width: 1)
                .frame(height: bodyView.size.height*4/20)
                
                
                // Servo3
                VStack(spacing: 0) {
                  SwiftUINormalSlider(trackColor: .yellow, value: self.$bDriver.sliderValueSrv3)
                  .frame(width: bodyView.size.width/3/*, height: bodyView.size.height*6/20*/)
                  .hidden(self.$bDriver.config.srv3Hide)
                  .hidden(self.$bDriver.srv3LabelHide)
                  .disabled(self.bDriver.config.srv3Sync)
                  .id(!self.bDriver.config.srv3Sync)
                  .disabled(self.bDriver.gameControllerConnected)
                  .id(!self.bDriver.gameControllerConnected)
                  .disabled(self.$bDriver.config.srv3Motion.wrappedValue != 1)
                  .id(self.$bDriver.config.srv3Motion.wrappedValue)
                }
                //.border(Color.red, width: 1)
                .frame(height: bodyView.size.height*4/20)
                
                // Servo4
                VStack(spacing: 0) {
                  SwiftUINormalSlider(trackColor: .yellow, value: self.$bDriver.sliderValueSrv4)
                  .frame(width: bodyView.size.width/3/*, height: bodyView.size.height*6/20*/)
                  .hidden(self.$bDriver.config.srv4Hide)
                  .hidden(self.$bDriver.srv4LabelHide)
                  .disabled(self.bDriver.config.srv4Sync)
                  .id(!self.bDriver.config.srv4Sync)
                  .disabled(self.bDriver.gameControllerConnected)
                  .id(!self.bDriver.gameControllerConnected)
                  .disabled(self.$bDriver.config.srv4Motion.wrappedValue != 1)
                  .id(self.$bDriver.config.srv4Motion.wrappedValue)
                }
                //.border(Color.red, width: 1)
                .frame(height: bodyView.size.height*4/20)
              }
              .frame(width: bodyView.size.width/10*4)

              // X2 Slider Mot1,2
              VStack(spacing: 0) {
                
                VStack(spacing: 0) {
                  VStack(spacing: 0) {
                  ZStack() {
                    RoundedRectangle(cornerRadius: 50)
                    .stroke(Color.blue, lineWidth: 3)
                    .frame(width:bodyView.size.height/20*14, height: bodyView.size.height/20*14)
                    
                    Circle()
                    .fill(Color.white)
                    .frame(width:50, height: 50)
                    .position(x: self.posX, y: self.posY)
                    .onAppear() {
                      self.posX = bodyView.size.height/20*7
                      self.posY = bodyView.size.height/20*7
                    }
                    .gesture(
                      DragGesture()
                      .onChanged { value in
                        var tmpX : CGFloat = value.startLocation.x +  value.translation.width
                        var tmpY : CGFloat = value.startLocation.y +  value.translation.height
                        
                        if (tmpX < 25) {
                          tmpX = 25
                        }
                        if (tmpX > bodyView.size.height/20*14-25) {
                          tmpX = bodyView.size.height/20*14-25
                        }
                        if (tmpY < 25) {
                          tmpY = 25
                        }
                        if (tmpY > bodyView.size.height/20*14-25) {
                          tmpY = bodyView.size.height/20*14-25
                        }
                        self.posX = tmpX
                        self.posY = tmpY
                        
                        let x : Double = Double(tmpX - (bodyView.size.height/20*7))/(bodyView.size.height/20*7-25)     // +1.0 --- -1.0
                        let y : Double = Double(tmpY - (bodyView.size.height/20*7))/(bodyView.size.height/20*7-25)     // +1.0 --- -1.0
                        
                        var m2 : Double = (y+1.0)/2.0*100
                        var m1 : Double = (y+1.0)/2.0*100
                        if (x > 0) {
                          m2 = m2 * (1.0-x)
                        }
                        if (x < 0) {
                          m1 = m1 * (1.0+x)
                        }
                        print("\(x) / \(y) , \(m1) / \(m2)")
                        
                        self.bDriver.sliderValueMot1 = m1
                        self.bDriver.sliderValueMot2 = m2
                      }
                      .onEnded { value in
                        self.posX = bodyView.size.height/20*7
                        self.posY = bodyView.size.height/20*7
                        //print(\(self.posX - bodyView.size.height/20*7) + " / " + \(self.posY - bodyView.size.height/20*7))
                        self.bDriver.sliderValueMot1 = 50
                        self.bDriver.sliderValueMot2 = 50
                      }
                    )
                    .disabled(self.bDriver.gameControllerConnected)
                    .id(!self.bDriver.gameControllerConnected)
                    .hidden(self.$bDriver.gameControllerConnected)
                  }
                  }
                  .frame(width:bodyView.size.height/20*14, height: bodyView.size.height/20*14)
                }
                .frame(height: bodyView.size.height/20*15)
                
                HStack(spacing: 0) {
                  
                  Spacer()
                  
                  VStack(spacing: 0) {
                    Text("Mot1")
                    .hidden(self.$bDriver.mot1LabelHide)
                    .onTapGesture(count: 3) { print("Mot1 Setting On!"); self.mot1SettingHide = false }
                  }
                  .frame(height: bodyView.size.height/20)
                  
                  Spacer()
                  
                  VStack(spacing: 0) {
                    Text("Mot2")
                    .hidden(self.$bDriver.mot2LabelHide)
                    .onTapGesture(count: 3) { print("Mot2 Setting On!"); self.mot2SettingHide = false }
                  }
                  .frame(height: bodyView.size.height/20)
                  
                  Spacer()
                  
                }
                .frame(height: bodyView.size.height/20)
              }
              .frame(width: bodyView.size.width/10*5)
            }
            .background(Color.gray)
            .frame(width: bodyView.size.width, height: bodyView.size.height*16/20)
            .hidden(self.$bDriver.style4Hide)
            //
            // Style H4sX2m
            //
            
            //
            // Style MX
            //
            HStack(spacing: 0) {
              
              // Steering
              VStack(spacing: 0) {
                
                // Steering
                VStack(spacing: 0) {
                  VStack(spacing: 0) {
                    ZStack() {
                      Capsule()
                      .stroke(Color.yellow, lineWidth: 3)
                      .frame(width:bodyView.size.height/20*14, height: 100)
                      
                      Circle()
                      .fill(Color.white)
                      .frame(width:80, height: 80)
                      .position(x: self.bDriver.posMXSX, y: bodyView.size.height/20*7)
                      .onAppear() {
                        self.bDriver.posMXSX  = bodyView.size.height/20*7
                        self.bDriver.posMXSX0 = bodyView.size.height/20*7
                        self.bDriver.posMXSX1 = bodyView.size.height/20*7-40
                      }
                      .gesture(
                        DragGesture()
                        .onChanged { value in
                          var tmpX : CGFloat = value.startLocation.x +  value.translation.width
                          
                          if (tmpX < 40) {
                            tmpX = 40
                          }
                          if (tmpX > bodyView.size.height/20*14-40) {
                            tmpX = bodyView.size.height/20*14-40
                          }
                          self.bDriver.posMXSX = tmpX
                          
                          let x : Double = Double(self.bDriver.posMXSX - (bodyView.size.height/20*7))/(bodyView.size.height/20*7-40)     // +1.0 --- -1.0
                          
                          let str : Double = (x+1.0)/2.0*100
                          if self.bDriver.config.srv1Motion == 1 {
                            self.bDriver.sliderValueSrv1 = str
                          }
                          if self.bDriver.config.srv2Sync {
                            self.bDriver.sliderValueSrv2 = self.bDriver.sliderValueSrv1
                          }
                          if self.bDriver.config.srv3Sync {
                            self.bDriver.sliderValueSrv3 = self.bDriver.sliderValueSrv1
                          }
                          if self.bDriver.config.srv4Sync {
                            self.bDriver.sliderValueSrv4 = self.bDriver.sliderValueSrv1
                          }
                        }
                        .onEnded { value in
                          var tmpX : CGFloat = value.startLocation.x +  value.translation.width
                          
                          if (tmpX < 40) {
                            tmpX = 40
                          }
                          if (tmpX > bodyView.size.height/20*14-40) {
                            tmpX = bodyView.size.height/20*14-40
                          }
                          self.bDriver.posMXSX = tmpX
                          
                          let x : Double = Double(self.bDriver.posMXSX - (bodyView.size.height/20*7))/(bodyView.size.height/20*7-40)     // +1.0 --- -1.0
                          
                          let str : Double = (x+1.0)/2.0*100
                          if self.bDriver.config.srv1Motion == 1 {
                            self.bDriver.sliderValueSrv1 = str
                          }
                          if self.bDriver.config.srv2Sync {
                            self.bDriver.sliderValueSrv2 = self.bDriver.sliderValueSrv1
                          }
                          if self.bDriver.config.srv3Sync {
                            self.bDriver.sliderValueSrv3 = self.bDriver.sliderValueSrv1
                          }
                          if self.bDriver.config.srv4Sync {
                            self.bDriver.sliderValueSrv4 = self.bDriver.sliderValueSrv1
                          }
                        }
                      )
                      .disabled(self.bDriver.gameControllerConnected)
                      .id(!self.bDriver.gameControllerConnected)
                      .hidden(self.$bDriver.gameControllerConnected)
                      .disabled(self.$bDriver.config.srv1Motion.wrappedValue != 1)
                      .id(self.$bDriver.config.srv1Motion.wrappedValue)
                      
                    }
                  }
                  .frame(width:bodyView.size.height/20*14, height: bodyView.size.height/20*14)
                }
                .frame(height: bodyView.size.height/20*15)
                
                // Label Srv1,2,3,4
                HStack(spacing: 0) {
                  Spacer()
                  VStack(spacing: 0) {
                    Text("Srv1")
                    .hidden(self.$bDriver.srv1LabelHide)
                    .onTapGesture(count: 3) { print("Srv1 Setting On!"); self.srv1SettingHide = false }
                  }
                  .frame(height: bodyView.size.height/20)
                  Spacer()
                  VStack(spacing: 0) {
                    Text("Srv2")
                    .hidden(self.$bDriver.srv2LabelHide)
                    .onTapGesture(count: 3) { print("Srv2 Setting On!"); self.srv2SettingHide = false }
                  }
                  .frame(height: bodyView.size.height/20)
                  Spacer()
                  VStack(spacing: 0) {
                    Text("Srv3")
                    .hidden(self.$bDriver.srv3LabelHide)
                    .onTapGesture(count: 3) { print("Srv3 Setting On!"); self.srv3SettingHide = false }
                  }
                  .frame(height: bodyView.size.height/20)
                  Spacer()
                  VStack(spacing: 0) {
                    Text("Srv4")
                    .hidden(self.$bDriver.srv2LabelHide)
                    .onTapGesture(count: 3) { print("Srv4 Setting On!"); self.srv4SettingHide = false }
                  }
                  .frame(height: bodyView.size.height/20)
                  Spacer()
                }
                .frame(height: bodyView.size.height/20)
              }
              .frame(width: bodyView.size.width/2)

              // throttle
              VStack(spacing: 0) {
                
                VStack(spacing: 0) {
                  VStack(spacing: 0) {
                    ZStack() {
                      Capsule()
                      .stroke(Color.blue, lineWidth: 3)
                      .frame(width:100, height: bodyView.size.height/20*14)
                      
                      Circle()
                      .fill(Color.white)
                      .frame(width:80, height: 80)
                      .position(x: bodyView.size.height/20*7, y: self.posMXTY)
                      .onAppear() {
                        self.posMXTY = bodyView.size.height/20*7
                      }
                      .gesture(
                        DragGesture()
                        .onChanged { value in
                          var tmpY : CGFloat = value.startLocation.y +  value.translation.height
                          
                          if (tmpY < 40) {
                            tmpY = 40
                          }
                          if (tmpY > bodyView.size.height/20*14-40) {
                            tmpY = bodyView.size.height/20*14-40
                          }
                          self.posMXTY = tmpY
                          
                          let y : Double = Double(tmpY - (bodyView.size.height/20*7))/(bodyView.size.height/20*7-40)     // +1.0 --- -1.0
                          
                          let m2 : Double = (y+1.0)/2.0*100
                          self.bDriver.sliderValueMot1 = 50.0
                          self.bDriver.sliderValueMot2 = m2
                        }
                        .onEnded { value in
                          self.posMXTY = bodyView.size.height/20*7
                          //print(\(self.posX - bodyView.size.height/20*7) + " / " + \(self.posY - bodyView.size.height/20*7))
                          self.bDriver.sliderValueMot1 = 50
                          self.bDriver.sliderValueMot2 = 50
                        }
                      )
                      .disabled(self.bDriver.gameControllerConnected)
                      .id(!self.bDriver.gameControllerConnected)
                      .hidden(self.$bDriver.gameControllerConnected)
                    }
                  }
                  .frame(width:bodyView.size.height/20*14, height: bodyView.size.height/20*14)
                }
                .frame(height: bodyView.size.height/20*15)
                
                HStack(spacing: 0) {
                  Spacer()
                  VStack(spacing: 0) {
                    Text("Mot2")
                    .hidden(self.$bDriver.mot2LabelHide)
                    .onTapGesture(count: 3) { print("Mot2 Setting On!"); self.mot2SettingHide = false }
                  }
                  .frame(height: bodyView.size.height/20)
                  Spacer()
                }
                .frame(height: bodyView.size.height/20)
              }
              .frame(width: bodyView.size.width/10*5)
            }
            .background(Color.gray)
            .frame(width: bodyView.size.width, height: bodyView.size.height*16/20)
            .hidden(self.$bDriver.style5Hide)
            //
            // Style MX
            //

            
            
            
            
            
            
            
            

          
          } // end of ZStuck for Styles
          .frame(width: bodyView.size.width, height: bodyView.size.height*16/20)
        }
        //
        // end of main control view
        //
        
        
        //
        // Setting view
        //
        VStack(spacing: 0) {
          //VStack() {
          //  Spacer()
          //}
          //.frame(width: bodyView.size.width, height: bodyView.size.height/20*2)
          
          ZStack {
            
            VStack() {
              Text("bCore Name Setting")
                .font(.title)
                .frame(maxWidth: .infinity, alignment: .center)
              //
              Spacer()
              
              Text("Enter New Name")
                .frame(maxWidth: .infinity, alignment: .leading)
              TextField("Enter New Name" , text: self.$bDriver.newName)
              //TextField("enter new name" , text: self.$iDriver.config.name)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding(.horizontal)
              
              Spacer()
              
              HStack() {
                Text("Style")
                Picker(selection: self.$bDriver.config.style, label: Text("Style")) {
                  Text("V6ms").tag(1)
                  Text("V2mH4s").tag(2)
                  Text("H6ms").tag(3)
                  Text("H4sX2m").tag(4)
                  Text("MX").tag(5)
                }
                .pickerStyle(SegmentedPickerStyle())
                .onChange(of: self.bDriver.config.style) { newValue in
                  print("Style changed to \(newValue)")
                  self.bDriver.styleUpdate()
                }
              }
              
              Spacer()
              
              Button(action: {
                self.nameSettingHide = true
                if (self.bDriver.newName != "") {
                  self.bDriver.config.name = self.bDriver.newName
                  self.bDriver.connectionStatus = self.bDriver.config.name
                }
                self.bDriver.saveConfig()
              }) {Text("Close").padding(.horizontal)}
                .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color.blue, lineWidth: 1))
                //.frame(alignment: .bottom)
              Spacer()
                //.frame(alignment: .bottom)
            }
            .frame(alignment: .bottom)
            .background(Color.white)
            .hidden(self.$nameSettingHide)
            
            VStack() {
              Text("Mot1 Setting")
                .font(.title)
                .frame(maxWidth: .infinity, alignment: .center)
              Toggle(isOn: self.$bDriver.config.mot1Flip) {Text("Flip")}.padding(.horizontal)
              Toggle(isOn: self.$bDriver.config.mot1Hide) {Text("Hide")}.padding(.horizontal)
              Spacer()
              Button(action: {self.mot1SettingHide = true; self.bDriver.saveConfig() }) {Text("Close").padding(.horizontal)}
                .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color.blue, lineWidth: 1))
              Spacer()
            }
            .frame(alignment: .bottom)
            .background(Color.white)
            .hidden(self.$mot1SettingHide)
            
            VStack() {
              Text("Mot2 Setting")
                .font(.title)
                .frame(maxWidth: .infinity, alignment: .center)
              Toggle(isOn: self.$bDriver.config.mot2Flip) {Text("Flip")}.padding(.horizontal)
              Toggle(isOn: self.$bDriver.config.mot2Hide) {Text("Hide")}.padding(.horizontal)
              Spacer()
              Button(action: {self.mot2SettingHide = true; self.bDriver.saveConfig() }) {Text("Close").padding(.horizontal)}
                .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color.blue, lineWidth: 1))
              Spacer()
            }
            .frame(alignment: .bottom)
            .background(Color.white)
            .hidden(self.$mot2SettingHide)
            
            VStack() {
              Text("Srv1 Setting")
                .font(.title)
                .frame(maxWidth: .infinity, alignment: .center)
              Spacer()
              Toggle(isOn: self.$bDriver.config.srv1Flip) {Text("Flip")}.padding(.horizontal)
              Toggle(isOn: self.$bDriver.config.srv1Hide) {Text("Hide")}.padding(.horizontal)
              HStack() {
                Text("Trim").padding(.horizontal)
                SwiftUINormalSlider(trackColor: .yellow, value: self.$bDriver.config.sliderValueSrv1Trim).padding(.horizontal)
              }
              HStack() {
                Text("Motion")
                Picker(selection: self.$bDriver.config.srv1Motion, label: Text("Motion")) {
                  Text("Srv1").tag(1)
                  Text("Roll").tag(2)
                  Text("Pitch").tag(3)
                  Text("Yaw").tag(4)
                }
                .pickerStyle(SegmentedPickerStyle())
              }
              Spacer()
              Button(action: {self.srv1SettingHide = true; self.bDriver.saveConfig() }) {Text("Close").padding(.horizontal)}
                .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color.blue, lineWidth: 1))
              Spacer()
            }
            .frame(alignment: .bottom)
            .background(Color.white)
            .hidden(self.$srv1SettingHide)
            
            VStack() {
              Text("Srv2 Setting")
                .font(.title)
                .frame(maxWidth: .infinity, alignment: .center)
              Spacer()
              Toggle(isOn: self.$bDriver.config.srv2Flip) {Text("Flip")}.padding(.horizontal)
              Toggle(isOn: self.$bDriver.config.srv2Hide) {Text("Hide")}.padding(.horizontal)
              Toggle(isOn: self.$bDriver.config.srv2Sync) {Text("Sync to Srv1")}.padding(.horizontal)
              HStack() {
                Text("Trim").padding(.horizontal)
                SwiftUINormalSlider(trackColor: .yellow, value: self.$bDriver.config.sliderValueSrv2Trim).padding(.horizontal)
              }
              HStack() {
                Text("Motion")
                Picker(selection: self.$bDriver.config.srv2Motion, label: Text("Motion")) {
                  Text("Srv2").tag(1)
                  Text("Roll").tag(2)
                  Text("Pitch").tag(3)
                  Text("Yaw").tag(4)
                }
                .pickerStyle(SegmentedPickerStyle())
              }
              Spacer()
              Button(action: {self.srv2SettingHide = true; self.bDriver.saveConfig() }) {Text("Close").padding(.horizontal)}
                .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color.blue, lineWidth: 1))
              Spacer()
            }
            .frame(alignment: .bottom)
            .background(Color.white)
            .hidden(self.$srv2SettingHide)
            
            VStack() {
              Text("Srv3 Setting")
                .font(.title)
                .frame(maxWidth: .infinity, alignment: .center)
              Spacer()
              Toggle(isOn: self.$bDriver.config.srv3Flip) {Text("Flip")}.padding(.horizontal)
              Toggle(isOn: self.$bDriver.config.srv3Hide) {Text("Hide")}.padding(.horizontal)
              Toggle(isOn: self.$bDriver.config.srv3Sync) {Text("Sync to Srv1")}.padding(.horizontal)
              HStack() {
                Text("Trim").padding(.horizontal)
                SwiftUINormalSlider(trackColor: .yellow, value: self.$bDriver.config.sliderValueSrv3Trim).padding(.horizontal)
              }
              HStack() {
                Text("Motion")
                Picker(selection: self.$bDriver.config.srv3Motion, label: Text("Motion")) {
                  Text("Srv3").tag(1)
                  Text("Roll").tag(2)
                  Text("Pitch").tag(3)
                  Text("Yaw").tag(4)
                }
                .pickerStyle(SegmentedPickerStyle())
              }
              Spacer()
              Button(action: {self.srv3SettingHide = true; self.bDriver.saveConfig() }) {Text("Close").padding(.horizontal)}
                .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color.blue, lineWidth: 1))
              Spacer()
            }
            .frame(alignment: .bottom)
            .background(Color.white)
            .hidden(self.$srv3SettingHide)
            
            VStack() {
              Text("Srv4 Setting")
                .font(.title)
                .frame(maxWidth: .infinity, alignment: .center)
              Spacer()
              Toggle(isOn: self.$bDriver.config.srv4Flip) {Text("Flip")}.padding(.horizontal)
              Toggle(isOn: self.$bDriver.config.srv4Hide) {Text("Hide")}.padding(.horizontal)
              Toggle(isOn: self.$bDriver.config.srv4Sync) {Text("Sync to Srv1")}.padding(.horizontal)
              HStack() {
                Text("Trim").padding(.horizontal)
                SwiftUINormalSlider(trackColor: .yellow, value: self.$bDriver.config.sliderValueSrv4Trim).padding(.horizontal)
              }
              HStack() {
                Text("Motion")
                Picker(selection: self.$bDriver.config.srv4Motion, label: Text("Motion")) {
                  Text("Srv4").tag(1)
                  Text("Roll").tag(2)
                  Text("Pitch").tag(3)
                  Text("Yaw").tag(4)
                }
                .pickerStyle(SegmentedPickerStyle())
              }
              Spacer()
              Button(action: {self.srv4SettingHide = true; self.bDriver.saveConfig() }) {Text("Close").padding(.horizontal)}
                .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color.blue, lineWidth: 1))
              Spacer()
            }
            .frame(alignment: .bottom)
            .background(Color.white)
            .hidden(self.$srv4SettingHide)
                        
            VStack() {
              Text("Game Contoller Setting")
                .font(.title)
                .frame(maxWidth: .infinity, alignment: .center)
              Spacer()
              
              HStack() {
                Text("Srv1")
                Picker(selection: self.$bDriver.gcConfig.srv1Selecter, label: Text("Srv1")) {
                  Text("Left U/D").tag(1)
                  Text("Left L/R").tag(2)
                  Text("Right U/D").tag(3)
                  Text("Right L/R").tag(4)
                }
                .pickerStyle(SegmentedPickerStyle())
                //.frame(width: bodyView.size.width/4)
                //.labelsHidden()
              }
                
              HStack() {
                Text("Srv2")
                Picker(selection: self.$bDriver.gcConfig.srv2Selecter, label: Text("Srv2")) {
                  Text("Left U/D").tag(1)
                  Text("Left L/R").tag(2)
                  Text("Right U/D").tag(3)
                  Text("Right L/R").tag(4)
                }
                .pickerStyle(SegmentedPickerStyle())
                //.frame(width: bodyView.size.width/4)
                //.labelsHidden()
              }
              
              HStack() {
                Text("Srv3")
                Picker(selection: self.$bDriver.gcConfig.srv3Selecter, label: Text("Srv3")) {
                  Text("Left U/D").tag(1)
                  Text("Left L/R").tag(2)
                  Text("Right U/D").tag(3)
                  Text("Right L/R").tag(4)
                }
                .pickerStyle(SegmentedPickerStyle())
                //.frame(width: bodyView.size.width/4)
                //.labelsHidden()
              }
                
              HStack() {
                Text("Srv4")
                Picker(selection: self.$bDriver.gcConfig.srv4Selecter, label: Text("Srv4")) {
                  Text("Left U/D").tag(1)
                  Text("Left L/R").tag(2)
                  Text("Right U/D").tag(3)
                  Text("Right L/R").tag(4)
                }
                .pickerStyle(SegmentedPickerStyle())
                //.frame(width: bodyView.size.width/4)
                //.labelsHidden()
              }
              Spacer()
              Button(action: {self.gcSettingHide = true; self.bDriver.saveGCConfig() }) {Text("Close").padding(.horizontal)}
                .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color.blue, lineWidth: 1))
              Spacer()
            }
            .frame(alignment: .bottom)
            .background(Color.white)
            .hidden(self.$gcSettingHide)
            
            //
            // Debug Info
            //
            VStack() {
              Text("Mot1 \(self.$bDriver.sliderValueMot1.wrappedValue)")
              Text("Mot2 \(self.$bDriver.sliderValueMot2.wrappedValue)")
              Text("Srv1 \(self.$bDriver.sliderValueSrv1.wrappedValue)")
              Text("Srv2 \(self.$bDriver.sliderValueSrv2.wrappedValue)")
              Text("Srv3 \(self.$bDriver.sliderValueSrv3.wrappedValue)")
              Text("Srv4 \(self.$bDriver.sliderValueSrv4.wrappedValue)")
            }
            .background(Color.clear)
            .hidden(self.$debugInfoHide)
            
          } // ZStack for Setting Panels
          .frame(width: bodyView.size.width, height: bodyView.size.height)
        }
        //
        // end of setting view
        //
        
        //
        // BLE List View
        //
        VStack(spacing: 0) {
          
          //
          // BLE Device List
          //
          VStack() {
            Text("Select your bCore")
          }
          .frame(width: bodyView.size.width, height: bodyView.size.height/20)
          
          ZStack() {
            Rectangle()
              .fill(Color.white)
              .frame(width: bodyView.size.width, height: bodyView.size.height - bodyView.size.height/20)

            Image("logo_bcore")
              .resizable()
              .frame(width: bodyView.size.height/2, height: bodyView.size.height/2)
              .opacity(0.3)
            
            //VStack() {
              List {
                ForEach(0..<self.bDriver.bleList.count, id: \.self) { i in
                  VStack() {
                    Text("\(self.bDriver.bleList[i].name)")
                    Text("ID:\(self.bDriver.bleList[i].id)")
                      .font(.footnote)
                      .foregroundColor(self.bDriver.bleList[i].color)
                  }
                  //.background(Color.clear)
                  .onTapGesture(count: 1) {
                    print("List Tapped [" + self.bDriver.bleList[i].name + "]")
                    self.bDriver.bleConnect(id: self.bDriver.bleList[i].id, name: self.bDriver.bleList[i].name, peripheral: self.bDriver.bleList[i].peripheral)
                  }
                  .listRowBackground(Color.clear)
                }
                
                //.onSelect()
                //.onDelete(perform: self.wifiListRemove)
              //}
              //.background(Color.clear)
            }
          }
          .frame(width: bodyView.size.width, height: bodyView.size.height - bodyView.size.height/20)
          
        }
        .frame(width: bodyView.size.width, height: bodyView.size.height)
        .background(Color.gray)
        .hidden(self.$bDriver.hideBLEList)
        
        //
        // end of BLE List View
        //
        
        //
        //  BLE接続中のくるくる
        //
        VStack(spacing: 0) {
          ActivityIndicator(isAnimating: self.$bDriver.isWaitingForBLEConnection, style: .large)
        }
        .frame(width: bodyView.size.width, height: bodyView.size.height)
        .background(Color.white.opacity(0.7))
        
        .hidden(self.$bDriver.hideActivityIndicator)
      } // ZStack
      
    } // GeometryReader
    
    /*
    // 位置情報不許可時の終了警告表示
    .alert(isPresented: self.$bDriver.showQuitAlartLocationFail) {
      Alert(
        title: Text("位置情報の許可が必要です。"),
        message: Text("設定 >プライバシー >位置情報サービス >iDriver から許可を設定して下さい。"),
        dismissButton: .destructive(Text("終了"), action: { print("QuitApp"); exit(0) })
      )
    }
    //
    */
    
    // BLE切断終了警告表示
    .alert(isPresented: self.$bDriver.showQuitAlartConnectionLost) {
      Alert(
        title: Text("bCoreとの接続が切れました。"),
        message: Text("デバイスの状態を確認してアプリを再起動してください。"),
        dismissButton: .destructive(Text("終了"), action: { print("QuitApp"); exit(0) })
      )
    }
    
    //
    // Game Controller
    //
    .onReceive(NotificationCenter.default.publisher(for: .GCControllerDidConnect)) { notification in
      print("GCControllerDidConnect")
      self.bDriver.gameControllerConnected = true
      self.bDriver.gameControllerHide      = false
      
      guard let controller = notification.object as? GCController,
        let gamepad = controller.extendedGamepad else {
          return
        }
      print(String(describing: controller.vendorName))
      self.bDriver.gameControllerString = controller.vendorName!
      self.bDriver.loadGCConfig()
      handleGamePad(gamepad, bDriver)
    }
    
    .onReceive(NotificationCenter.default.publisher(for: .GCControllerDidDisconnect)) { notification in
      print("GCControllerDidDisConnect")
      self.bDriver.gameControllerConnected = false
      self.bDriver.gameControllerHide      = true
    }
    
    //
    //
    //
  }}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}


//
// ぐるぐる
//
struct ActivityIndicator: UIViewRepresentable {
    @Binding var isAnimating: Bool
    
    let style: UIActivityIndicatorView.Style

    func makeUIView(context: Context) -> UIActivityIndicatorView {
        UIActivityIndicatorView(style: style)
    }

    func updateUIView(_ uiView: UIActivityIndicatorView, context: Context) {
        isAnimating ? uiView.startAnimating() : uiView.stopAnimating()
    }
}

//
//  色付きスライダ
//
struct SwiftUISyncSlider: UIViewRepresentable {

  final class Coordinator: NSObject {
    // The class property value is a binding: It’s a reference to the SwiftUISlider
    // value, which receives a reference to a @State variable value in ContentView.
    var value: Binding<Double>
    //var mode : Bool
    
    var sync2: Binding<Bool>
    var sync3: Binding<Bool>
    var sync4: Binding<Bool>
    var value2: Binding<Double>
    var value3: Binding<Double>
    var value4: Binding<Double>
    
    // Create the binding when you initialize the Coordinator
    init(value: Binding<Double>, //mode: Bool//,
         sync2: Binding<Bool>, sync3: Binding<Bool>, sync4: Binding<Bool>,
         value2: Binding<Double>, value3: Binding<Double>, value4: Binding<Double>
    ) {
      self.value = value
      //self.mode  = mode
      self.sync2 = sync2
      self.sync3 = sync3
      self.sync4 = sync4
      self.value2 = value2
      self.value3 = value3
      self.value4 = value4
   }

    // Create a valueChanged(_:) action
    @objc func valueChanged(_ sender: UISlider) {
      self.value.wrappedValue = Double(sender.value)
      if (self.sync2.wrappedValue == true) {
        self.value2.wrappedValue = Double(sender.value)
      }
      if (self.sync3.wrappedValue == true) {
        self.value3.wrappedValue = Double(sender.value)
      }
      if (self.sync4.wrappedValue == true) {
        self.value4.wrappedValue = Double(sender.value)
      }
    }
    
    /*
    @objc func valueDidLeft(_ sender: UISlider) {
      //指を離した時の処理
      if (self.mode == true) {
        self.value.wrappedValue = 50.0
      }
    }
    */
  }
  
  //var mode: Bool = false
  var trackColor: UIColor?
  @Binding var value: Double
  
  @Binding var sync2: Bool
  @Binding var sync3: Bool
  @Binding var sync4: Bool
  @Binding var value2: Double
  @Binding var value3: Double
  @Binding var value4: Double

  func makeUIView(context: Context) -> UISlider {
    let slider = UISlider(frame: .zero)
    slider.thumbTintColor = .white
    slider.minimumTrackTintColor = trackColor
    slider.maximumTrackTintColor = trackColor
    slider.maximumValue = 100.0
    slider.minimumValue = 0.0
    slider.value = Float(value)

    slider.addTarget(
      context.coordinator,
      action: #selector(Coordinator.valueChanged(_:)),
      for: .valueChanged
    )
    /*
    slider.addTarget(
      context.coordinator,
      action: #selector(Coordinator.valueDidLeft(_:)),
      for: UIControl.Event.touchUpInside  // 指を離した時
    )
    */
    return slider
  }
  
  func updateUIView(_ uiView: UISlider, context: Context) {
    // Coordinating data between UIView and SwiftUI view
    uiView.value = Float(self.value)
  }

  func makeCoordinator() -> SwiftUISyncSlider.Coordinator {
    Coordinator(value: $value, //mode: mode,
                sync2: $sync2, sync3: $sync3, sync4: $sync4,
               value2: $value2, value3: $value3, value4: $value4
    )
  }
}

//
//  色付き戻りスライダ
//
struct SwiftUISpringSlider: UIViewRepresentable {

  final class Coordinator: NSObject {
    // The class property value is a binding: It’s a reference to the SwiftUISlider
    // value, which receives a reference to a @State variable value in ContentView.
    var value: Binding<Double>
    
    // Create the binding when you initialize the Coordinator
    init(value: Binding<Double>) {
      self.value = value
   }

    // Create a valueChanged(_:) action
    @objc func valueChanged(_ sender: UISlider) {
      self.value.wrappedValue = Double(sender.value)
    }
    
    @objc func valueDidLeft(_ sender: UISlider) {
      //指を離した時の処理
      self.value.wrappedValue = 50.0
    }
  }
  
  var trackColor: UIColor?
  @Binding var value: Double

  func makeUIView(context: Context) -> UISlider {
    let slider = UISlider(frame: .zero)
    slider.thumbTintColor = .white
    slider.minimumTrackTintColor = trackColor
    slider.maximumTrackTintColor = trackColor
    slider.maximumValue = 100.0
    slider.minimumValue = 0.0
    slider.value = Float(value)

    slider.addTarget(
      context.coordinator,
      action: #selector(Coordinator.valueChanged(_:)),
      for: .valueChanged
    )
    slider.addTarget(
      context.coordinator,
      action: #selector(Coordinator.valueDidLeft(_:)),
      for: UIControl.Event.touchUpInside  // 指を離した時
    )

    return slider
  }

  func updateUIView(_ uiView: UISlider, context: Context) {
    // Coordinating data between UIView and SwiftUI view
    uiView.value = Float(self.value)
  }

  func makeCoordinator() -> SwiftUISpringSlider.Coordinator {
    Coordinator(value: $value)
  }
}

//
//  色付きノーマルスライダ
//
struct SwiftUINormalSlider: UIViewRepresentable {

  final class Coordinator: NSObject {
    // The class property value is a binding: It’s a reference to the SwiftUISlider
    // value, which receives a reference to a @State variable value in ContentView.
    var value: Binding<Double>
    
    // Create the binding when you initialize the Coordinator
    init(value: Binding<Double>) {
      self.value = value
   }

    // Create a valueChanged(_:) action
    @objc func valueChanged(_ sender: UISlider) {
      self.value.wrappedValue = Double(sender.value)
    }
  }
  
  var trackColor: UIColor?
  @Binding var value: Double

  func makeUIView(context: Context) -> UISlider {
    let slider = UISlider(frame: .zero)
    slider.thumbTintColor = .white
    slider.minimumTrackTintColor = trackColor
    slider.maximumTrackTintColor = trackColor
    slider.maximumValue = 100.0
    slider.minimumValue = 0.0
    slider.value = Float(value)

    slider.addTarget(
      context.coordinator,
      action: #selector(Coordinator.valueChanged(_:)),
      for: .valueChanged
    )

    return slider
  }

  func updateUIView(_ uiView: UISlider, context: Context) {
    // Coordinating data between UIView and SwiftUI view
    uiView.value = Float(self.value)
  }

  func makeCoordinator() -> SwiftUINormalSlider.Coordinator {
    Coordinator(value: $value)
  }
}

//
// 部品に隠す属性をつける
//
struct Hidden: ViewModifier {
  @Binding var hidden: Bool
  
  func body(content: Content) -> some View {
    VStack {
      if !hidden {
        content
      }
    }
  }
}

extension View {
  func hidden(_ isHidden: Binding<Bool>) -> some View {
    ModifiedContent(content: self, modifier: Hidden(hidden: isHidden))
  }
}


// GamePad
func handleGamePad(_ gamepad: GCExtendedGamepad, _ bdriver: bCoreDriver) {
  // △ ○ × □
  var triangleButton: GCControllerButtonInput?
  var circleButton:   GCControllerButtonInput?
  var crossButton:    GCControllerButtonInput?
  var rectButton:     GCControllerButtonInput?
    
  // ↑ ← ↓ → key
  var directionPad: GCControllerDirectionPad?
    
  // thumbstich
  var leftThumbstick: GCControllerDirectionPad?
  var rightThumbstick: GCControllerDirectionPad?
  var leftThumbstickButton: GCControllerButtonInput?
  var rightThumbstickButton: GCControllerButtonInput?
  
  // L1, L2, R1, R2　button
  var l1Button: GCControllerButtonInput?
  var l2Button: GCControllerButtonInput?
  var r1Button: GCControllerButtonInput?
  var r2Button: GCControllerButtonInput?
    
  // setting
  var optionsButton: GCControllerButtonInput?
  var shareButton: GCControllerButtonInput?
  
  var leftCW  :Bool = true
  var rightCW :Bool = true
  
  var l2Pressed :Bool = false
  var r2Pressed :Bool = false

  // △ ○ × □
  rectButton = gamepad.buttonX
  triangleButton = gamepad.buttonY
  circleButton = gamepad.buttonB
  crossButton = gamepad.buttonA
    
  // ↑ ← ↓ → key
  directionPad = gamepad.dpad
    
  // thumbstich
  leftThumbstick = gamepad.leftThumbstick
  rightThumbstick = gamepad.rightThumbstick
  leftThumbstickButton = gamepad.leftThumbstickButton
  rightThumbstickButton = gamepad.rightThumbstickButton
    
  // L1, L2, R1, R2　button
  l1Button = gamepad.leftShoulder
  l2Button = gamepad.leftTrigger
  r1Button = gamepad.rightShoulder
  r2Button = gamepad.rightTrigger
    
  // setting
  optionsButton = gamepad.buttonMenu
  shareButton = gamepad.buttonOptions
    
  // △ ○ × □
  triangleButton?.pressedChangedHandler = { (input, value, isPressed) in guard isPressed else {return }
    print("press △")
    bdriver.buttonLED1Action()
  }
    
  circleButton?.pressedChangedHandler = { (input, value, isPressed) in guard isPressed else {return  }
    print("press ○")
    bdriver.buttonLED4Action()
  }
    
  crossButton?.pressedChangedHandler = { (input, value, isPressed) in guard isPressed else {return  }
    print("press ×")
    bdriver.buttonLED3Action()
  }
    
  rectButton?.pressedChangedHandler = { (input, value, isPressed) in guard isPressed else {return  }
    print("press □")
    bdriver.buttonLED2Action()
  }
    
  // ↑ ← ↓ → key
  directionPad?.valueChangedHandler = {(_ dPad: GCControllerDirectionPad,
                                           _ x: Float,
                                           _ y: Float) -> Void in
    if x == 0 && y == 0 {
      return
    }
    print("x: \(x), y: \(y)")
    
    if x == 1.0 {
      print("→")
    }
    
    if x == -1.0 {
      print("←")
    }
        
    if y == 1.0 {
      print("↑")
    }
        
    if y == -1.0 {
      print("↓")
    }
  }
    
  // thumbstich
  leftThumbstick?.valueChangedHandler = {(_ dpad: GCControllerDirectionPad,
                                        _ xValue: Float,
                                        _ yValue: Float) -> Void in
    print("left stick X: \(xValue)")
    print("left stick Y: \(yValue)")
    
    if bdriver.gcConfig.srv1Selecter == 1 {
      bdriver.sliderValueSrv1 = (Double)(50.0 + 50.0 * yValue)
    }
    if bdriver.gcConfig.srv2Selecter == 1 {
      bdriver.sliderValueSrv2 = (Double)(50.0 + 50.0 * yValue)
    }
    if bdriver.gcConfig.srv3Selecter == 1 {
      bdriver.sliderValueSrv3 = (Double)(50.0 + 50.0 * yValue)
    }
    if bdriver.gcConfig.srv4Selecter == 1 {
      bdriver.sliderValueSrv4 = (Double)(50.0 + 50.0 * yValue)
    }
    
    if bdriver.gcConfig.srv1Selecter == 2 {
      bdriver.sliderValueSrv1 = (Double)(50.0 + 50.0 * xValue)
    }
    if bdriver.gcConfig.srv2Selecter == 2 {
      bdriver.sliderValueSrv2 = (Double)(50.0 + 50.0 * xValue)
    }
    if bdriver.gcConfig.srv3Selecter == 2 {
      bdriver.sliderValueSrv3 = (Double)(50.0 + 50.0 * xValue)
    }
    if bdriver.gcConfig.srv4Selecter == 2 {
      bdriver.sliderValueSrv4 = (Double)(50.0 + 50.0 * xValue)
    }
  }
    
  rightThumbstick?.valueChangedHandler = {(_ dpad: GCControllerDirectionPad,
                                         _ xValue: Float,
                                         _ yValue: Float) -> Void in
    print("right stick X: \(xValue)")
    print("right stick Y: \(yValue)")
    
    if bdriver.gcConfig.srv1Selecter == 3 {
      bdriver.sliderValueSrv1 = (Double)(50.0 + 50.0 * yValue)
    }
    if bdriver.gcConfig.srv2Selecter == 3 {
      bdriver.sliderValueSrv2 = (Double)(50.0 + 50.0 * yValue)
    }
    if bdriver.gcConfig.srv3Selecter == 3 {
      bdriver.sliderValueSrv3 = (Double)(50.0 + 50.0 * yValue)
    }
    if bdriver.gcConfig.srv4Selecter == 3 {
      bdriver.sliderValueSrv4 = (Double)(50.0 + 50.0 * yValue)
    }
    
    if bdriver.gcConfig.srv1Selecter == 4 {
      bdriver.sliderValueSrv1 = (Double)(50.0 + 50.0 * xValue)
    }
    if bdriver.gcConfig.srv2Selecter == 4 {
      bdriver.sliderValueSrv2 = (Double)(50.0 + 50.0 * xValue)
    }
    if bdriver.gcConfig.srv3Selecter == 4 {
      bdriver.sliderValueSrv3 = (Double)(50.0 + 50.0 * xValue)
    }
    if bdriver.gcConfig.srv4Selecter == 4 {
      bdriver.sliderValueSrv4 = (Double)(50.0 + 50.0 * xValue)
    }
  }
    
  leftThumbstickButton?.valueChangedHandler = {(_ button: GCControllerButtonInput,
                                                 _ value: Float,
                                               _ pressed: Bool) -> Void in
    if pressed {
      print("left thumbstick pressed")
    }
  }
    
  rightThumbstickButton?.valueChangedHandler = {(_ button: GCControllerButtonInput,
                                                  _ value: Float,
                                                _ pressed: Bool) -> Void in
    if pressed {
      print("right thumbstick presded")
    }
  }
    
  // L1, L2, R1, R2　button
  l1Button?.valueChangedHandler = {(_ button: GCControllerButtonInput,
                                     _ value: Float,
                                   _ pressed: Bool) -> Void in
    if pressed {
      print("L1 Pressed")
      if (l2Pressed == false) {
        leftCW.toggle()
      }
    }
  }
    
  l2Button?.valueChangedHandler = {(_ button: GCControllerButtonInput,
                                     _ value: Float,
                                   _ pressed: Bool) -> Void in
    if pressed {
      print("L2 Pressed")
      l2Pressed = true
    } else {
      l2Pressed = false
    }
    print("L2: \(value)")
    if (leftCW) {
      bdriver.sliderValueMot1 = (Double)(50.0 + 50.0 * value)
    } else {
      bdriver.sliderValueMot1 = (Double)(50.0 - 50.0 * value)
    }
  }
    
  r1Button?.valueChangedHandler = {(_ button: GCControllerButtonInput,
                                     _ value: Float,
                                   _ pressed: Bool) -> Void in
    if pressed {
      print("R1 Pressed")
      if (r2Pressed == false) {
        rightCW.toggle()
      }
    }
  }
    
  r2Button?.valueChangedHandler = {(_ button: GCControllerButtonInput,
                                     _ value: Float,
                                   _ pressed: Bool) -> Void in
    if pressed {
      print("R2 Pressed")
      r2Pressed = true
    } else {
      r2Pressed = false
    }
    print("R2: \(value)")
    if (rightCW) {
      bdriver.sliderValueMot2 = (Double)(50.0 + 50.0 * value)
    } else {
      bdriver.sliderValueMot2 = (Double)(50.0 - 50.0 * value)
    }
  }
    
  // setting
  optionsButton?.valueChangedHandler = {(_ button: GCControllerButtonInput,
                                          _ value: Float,
                                        _ pressed: Bool) -> Void in
    if pressed {
      print("OPTIONS tapped")
    }
  }
    
  shareButton?.valueChangedHandler = {(_ button: GCControllerButtonInput,
                                        _ value: Float,
                                      _ pressed: Bool) -> Void in
    if pressed {
      print("share tapped")
    }
  }
  
  return
}





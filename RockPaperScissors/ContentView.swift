//
//  ContentView.swift
//  RockPaperScissors
//
//  Created by Jack Cotton-Brown on 28/11/21.
//

/*
 Todo:
 - show an alert when the game reaches 10 questions
 - Use a Hstack and ForEach to create buttons for the player move options. Use emojis for the buttons.
 - Animate the emojis to scale up and down in size
 - When the player presses their attack selection, evaluate which side will win.
 */

import Foundation
import Speech
import SwiftUI
import AVFoundation

struct ContentView: View {
    @State var numberOfQuestions = 0 //should count up to 10, and then reset the game.
    @State var playerScore = 0
    @State var availableMoves = ["🪨", "📜", "✂️"].shuffled()
    @State var computerMove = Int.random(in: 0...2)
    @State var playerMove = ""
    @State private var emojiFontSize: CGFloat = 100
    
    private var gameOutcome: String {
        if availableMoves[computerMove] == playerMove{
            return "Tie"
        } else if availableMoves[computerMove] == "📜" && playerMove == "🪨"{
            return "Computer Wins"
        } else if availableMoves[computerMove] == "✂️" && playerMove == "📜"{
            return "Computer Wins"
        } else if availableMoves[computerMove] == "🪨" && playerMove == "✂️"{
            return "Computer Wins"
        } else {
            return "Player Wins"
        }
    }

    @State var showingEndGameAlert = false
    private let speechRecognizer = SpeechRecognizer()
    @State private var transcript = "Say your move"
    @State private var fired = ""
    
    var body: some View {
        ZStack{
            Color(red: 1, green: 0.5, blue: 1, opacity: 0.3).ignoresSafeArea()
            Text(transcript).onChange(of: transcript){ _ in
                if transcript.contains("paper"){
                    playerMove = availableMoves[availableMoves.firstIndex(of: "📜")!]
                    playSound(selectedEmoji: playerMove)
                    calculateGameOutcome(playerMove)
                    fired = "paper"

                }
                if transcript.contains("rock"){
                    playerMove = availableMoves[availableMoves.firstIndex(of: "🪨")!]
                    playSound(selectedEmoji: playerMove)
                    calculateGameOutcome(playerMove)
                    fired = "rock"


                }
                if transcript.contains("scissors"){
                    playerMove = availableMoves[availableMoves.firstIndex(of: "✂️")!]
                    playSound(selectedEmoji: playerMove)
                    calculateGameOutcome(playerMove)
                    fired = "scissors"
                }
                
            }.hidden()
            Text(fired)
            VStack{
                Text("The game will choose:")
                    .font(.largeTitle.weight(.heavy))
                Text("\(availableMoves[computerMove])")
                    .modifier(AnimatableCustomFontModifier(name: "System", size: emojiFontSize))
                    .onAppear {
                        withAnimation(.easeInOut(duration: 0.5).repeatForever()) {
                            emojiFontSize = 120
                        }
                    }
                Spacer()
            
                .padding()
                HStack{
                    ForEach(0...2, id: \.self){ option in
                        Button("\(availableMoves[option])"){
                            if numberOfQuestions > 8{
                                showingEndGameAlert.toggle()
                            }
                            playerMove = availableMoves[option]
                            playSound(selectedEmoji: playerMove)
                            calculateGameOutcome(playerMove)
   
                        }
                        .font(.system(size: 100))
                        .padding(5)

                    }
                    .onAppear{
                        withAnimation{
                            
                        }
                    }
                    
                    
                }
                HStack{
                    
                    Text("Score:")
                        .font(.title.weight(.heavy))
                        .padding(15)
                        
                        
                    Text("\(playerScore)")
                        .font(.title.weight(.heavy))
                        .foregroundColor(playerScore == 0 ? .red : .blue)
                    Spacer()
                    Text("\(numberOfQuestions)")
                        .padding()
                    

                }
                .frame(width: 350, height: 50, alignment: .center)
                .padding(5)
                .clipShape(Capsule(style: .circular))
                .background(.thinMaterial).border(.secondary).padding()
                
            }
            
        }
        .onAppear {
            speechRecognizer.record(to: $transcript)
        }
        .alert("Game Complete!", isPresented: $showingEndGameAlert){
            Button("Reset Game"){
                resetGame()
            }
        }
    }
    func playSound(selectedEmoji: String){
        var player = AVPlayer()
        var url: URL
    var emojiString: String = ""

        switch selectedEmoji{
        case "📜":
            emojiString = "paper"
        case "✂️":
            emojiString = "scissors"
        case "🪨":
            emojiString = "rock"
        default:
            print("Something wrong with setting the URL for the sound effect")
        }
        
        url = Bundle.main.url(forResource: emojiString, withExtension: ".wav")!
        
            player = AVPlayer(url: url)
            player.play()

    }
    
    func calculateGameOutcome(_ playerChoice: String){
        switch gameOutcome{
        case "Tie":
            playerScore += 0
            numberOfQuestions += 1

        case "Computer Wins":
            playerScore += 0
            numberOfQuestions += 1

        case "Player Wins":
            playerScore += 1
            numberOfQuestions += 1
            
        default:
            playerScore += 0 //this is irrelevant. The default case should never trigger. Can fix with an enum.
        }
        availableMoves = ["🪨", "📜", "✂️"].shuffled()
        computerMove = Int.random(in: 0...2)
        speechRecognizer.record(to: $transcript)
    }
    
    func resetGame(){
        //Reset the player score and counters back to zero
        numberOfQuestions = 0
        playerScore = 0
        
    }
}

//struct endGameAlert: ViewModifier {
//    @Binding var showingEndGameAlert: Bool
//    func body(content: Content) -> some View {
//        content
//            .alert("Game finished!", isPresented: $showingEndGameAlert){
//                resetGame()
//            }
//    }
//}

struct AnimatableCustomFontModifier: AnimatableModifier {
    var name: String
    var size: CGFloat

    var animatableData: CGFloat {
        get { size }
        set { size = newValue }
    }

    func body(content: Content) -> some View {
        content
            .font(.custom(name, size: size))
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

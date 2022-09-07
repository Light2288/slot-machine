//
//  ContentView.swift
//  Slot Machine
//
//  Created by Davide Aliti on 04/09/22.
//

import SwiftUI

struct ContentView: View {
    // MARK: - Properties
    let symbols = ["gfx-bell", "gfx-cherry", "gfx-coin", "gfx-grape", "gfx-seven", "gfx-strawberry"]
    enum SpinOutcome {
        case win
        case loss
    }
    
    @State private var reels: Array = [0, 1, 2]
    @State private var showingInfoView: Bool = false
    @State private var highScore: Int = UserDefaults.standard.integer(forKey: "Highscore")
    @State private var playerCoins: Int = 100
    @State private var betAmount: Int = 10
    @State private var animatingSymbol: Bool = false
    @State private var animatingModal: Bool = false
    
    private var isActiveBet10: Bool {
        return betAmount == 10
    }
    private var isActiveBet20: Bool {
        return betAmount == 20
    }
    private var isGameOver: Bool {
        playerCoins <= 0
    }
    
    // MARK: - Functions
    func setBetAmount(newBetAmount: Int) {
        betAmount = newBetAmount
        playSound(sound: "casino-chips", type: "mp3")
    }
    
    func spinReels() {
        reels = reels.map { _ in Int.random(in: 0..<symbols.count) }
        playSound(sound: "spin", type: "mp3")
    }
    
    func manageSpinOutcome() {
        if isWin() {
            updatePlayerCoins(spinOutcome: .win)
            updateHighscore()
        } else {
            updatePlayerCoins(spinOutcome: .loss)
        }
    }
    
    func isWin() -> Bool {
        return reels.allSatisfy({ $0 == reels[0] })
    }
    
    func updatePlayerCoins(spinOutcome: SpinOutcome) {
        playerCoins += spinOutcome == .win ? betAmount*10 : -betAmount
    }
    
    func updateHighscore() {
        if playerCoins > highScore {
            playSound(sound: "high-score", type: "mp3")
        } else {
            playSound(sound: "win", type: "")
        }
        highScore = max(highScore, playerCoins)
        UserDefaults.standard.set(highScore, forKey: "Highscore")
    }
    
    func restartGame() {
        self.animatingModal = false
        self.betAmount = 10
        playerCoins = 100
        playSound(sound: "chimeup", type: "mp3")
    }
    
    func resetGame() {
        UserDefaults.standard.set(0, forKey: "Highscore")
        highScore = 0
        playerCoins = 100
        betAmount = 10
    }
    
    // MARK: - Body
    var body: some View {
        ZStack {
            LinearGradient(gradient: Gradient(colors: [Color("ColorPink"), Color("ColorPurple")]), startPoint: .top, endPoint: .bottom)
                .edgesIgnoringSafeArea(.all)
            VStack(alignment: .center, spacing: 5) {
                LogoView()
                
                Spacer()
                
                HStack {
                    HStack {
                        Text("Your\nCoins".uppercased())
                            .scoreLabelStyle()
                            .multilineTextAlignment(.trailing)
                        Text("\(playerCoins)")
                            .scoreNumberStyle()
                            .modifier(ScoreNumberModifier())
                    }
                    .modifier(ScoreContainerModifier())
                    
                    Spacer()
                    
                    HStack {
                        Text("\(highScore)")
                            .scoreNumberStyle()
                            .modifier(ScoreNumberModifier())
                        Text("High\nScore".uppercased())
                            .scoreLabelStyle()
                            .multilineTextAlignment(.leading)
                    }
                    .modifier(ScoreContainerModifier())
                }
                
                VStack(alignment: .center, spacing: 0) {
                    ZStack {
                        ReelView()
                        Image(symbols[reels[1]])
                            .resizable()
                            .modifier(ImageModifier())
                            .opacity(animatingSymbol ? 1 : 0)
                            .offset(y: animatingSymbol ? 0 : -50)
                            .animation(.easeOut(duration: Double.random(in: 0.5...0.7)), value: animatingSymbol)
                            .onAppear {
                                self.animatingSymbol.toggle()
                                playSound(sound: "riseup", type: "mp3")
                            }
                    }
                    
                    HStack(alignment: .center, spacing: 0) {
                        ZStack {
                            ReelView()
                            Image(symbols[reels[0]])
                                .resizable()
                                .modifier(ImageModifier())
                                .opacity(animatingSymbol ? 1 : 0)
                                .animation(.easeOut(duration: Double.random(in: 0.7...0.9)), value: animatingSymbol)
                                .offset(y: animatingSymbol ? 0 : -50)

                                
                        }
                        Spacer()
                        ZStack {
                            ReelView()
                            Image(symbols[reels[2]])
                                .resizable()
                                .modifier(ImageModifier())
                                .opacity(animatingSymbol ? 1 : 0)
                                .animation(.easeOut(duration: Double.random(in: 0.9...1.1)), value: animatingSymbol)
                                .offset(y: animatingSymbol ? 0 : -50)
                        }
                    }
                    .frame(maxWidth: 500)
                    
                    Button {
                        withAnimation {
                            self.animatingSymbol = false
                        }
                        spinReels()
                        withAnimation {
                            self.animatingSymbol = true
                        }
                        manageSpinOutcome()
                    } label: {
                        Image("gfx-spin")
                            .renderingMode(.original)
                            .resizable()
                            .modifier(ImageModifier())
                    }
                    
                }
                .layoutPriority(2)
                
                Spacer()
                
                HStack {
                    HStack(alignment: .center, spacing: 10) {
                        Button {
                            setBetAmount(newBetAmount: 10)
                        } label: {
                            Text("10")
                                .fontWeight(.heavy)
                                .foregroundColor(isActiveBet10 ? Color("ColorYellow") : .white)
                                .modifier(BetNumberModifier())
                        }
                        .modifier(BetCapsuleModifier())
                        
                        Image("gfx-casino-chips")
                            .resizable()
                            .offset(x: isActiveBet10 ? 0 : -20)
                            .opacity(isActiveBet10 ? 1 : 0)
                            .modifier(CasinoChipsModifier())
                    }
                    
                    Spacer()
                    
                    HStack(alignment: .center, spacing: 10) {
                        Image("gfx-casino-chips")
                            .resizable()
                            .offset(x: isActiveBet20 ? 0 : 20)
                            .opacity(isActiveBet20 ? 1 : 0)
                            .modifier(CasinoChipsModifier())
                        
                        Button {
                            setBetAmount(newBetAmount: 20)
                        } label: {
                            Text("20")
                                .fontWeight(.heavy)
                                .foregroundColor(isActiveBet20 ? Color("ColorYellow") : .white)
                                .modifier(BetNumberModifier())
                        }
                        .modifier(BetCapsuleModifier())
                    }
                }
                
                
            } // VStack
            .overlay(
                Button(action: {
                    resetGame()
                }, label: {
                    Image(systemName: "arrow.2.circlepath.circle")
                })
                .modifier(ButtonModifier()),
                alignment: .topLeading
            )
            .overlay(
                Button(action: {
                    self.showingInfoView = true
                }, label: {
                    Image(systemName: "info.circle")
                })
                .modifier(ButtonModifier()),
                alignment: .topTrailing
            )
            .padding()
            .frame(maxWidth: 720)
            .blur(radius: isGameOver ? 5 : 0, opaque: false)
            
            if isGameOver {
                ZStack {
                    Color("ColorTransparentBlack")
                        .edgesIgnoringSafeArea(.all)
                    VStack(spacing: 0) {
                        Text("GAME OVER")
                            .font(.system(.title, design: .rounded))
                            .fontWeight(.heavy)
                            .padding()
                            .frame(minWidth: 0, maxWidth: .infinity)
                            .background(Color("ColorPink"))
                            .foregroundColor(.white)
                        
                        Spacer()
                        
                        VStack(alignment: .center, spacing: 16) {
                            Image("gfx-seven-reel")
                                .resizable()
                                .scaledToFit()
                                .frame(maxHeight: 72)
                            
                            Text("Bad luck! You lost all of the coins. \nLet's play again")
                                .font(.system(.body, design: .rounded))
                                .lineLimit(12)
                                .multilineTextAlignment(.center)
                                .foregroundColor(.gray)
                                .layoutPriority(1)
                            
                            Button {
                                restartGame()
                            } label: {
                                Text("New game".uppercased())
                                    .font(.system(.body, design: .rounded))
                                    .fontWeight(.semibold)
                                    .accentColor(Color("ColorPink"))
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 8)
                                    .frame(minWidth: 128)
                                    .background(
                                        Capsule()
                                            .strokeBorder(lineWidth: 1.75)
                                            .foregroundColor(Color("ColorPink"))
                                    )
                            }

                        }
                        
                        Spacer()
                    }
                    .frame(minWidth: 280, idealWidth: 280, maxWidth: 320, minHeight: 260, idealHeight: 260, maxHeight: 320, alignment: .center)
                    .background(.white)
                    .cornerRadius(20)
                    .shadow(color: Color("ColorTransparentBlack"), radius: 6, x: 0, y: 0)
                    .opacity($animatingModal.wrappedValue ? 1 : 0)
                    .offset(y: $animatingModal.wrappedValue ? 0 : -100)
                    .animation(.spring(response: 0.6, dampingFraction: 1.0, blendDuration: 1.0), value: animatingModal)
                    .onAppear {
                        playSound(sound: "game-over", type: "mp3")
                        self.animatingModal = true
                    }
                    
                }
            }
        } // ZStack
        .sheet(isPresented: self.$showingInfoView) {
            InfoView()
        }
    }
}

// MARK: - Preview
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

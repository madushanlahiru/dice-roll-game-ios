//
//  ContentView.swift
//  dicegame
//
//  Created by Madhushan Lahiru on 2022-12-24.
//

import SwiftUI

struct ContentView: View {

    @State var playerScores:[(threes:Int, twos:Int)] = Array(repeating: (threes: 0, twos: 0), count: 4)
    @State var cpuScores:[(threes:Int, twos:Int)] = Array(repeating: (threes: 0, twos: 0), count: 4)
    @State var gameQuarter = 1
    @State var buttonLabel = "Start the game"
    @State var gameStatus = "Ready to Roll"
    
    /// String array contains button labels.
    let buttonLabels = ["Roll first quarter", "Roll second quarter", "Roll third quarter", "Roll fourth quarter", "Play again"]

    var body: some View {
        VStack {
            Spacer()
            Text("Dice Roll Game")
                .fontWeight(.bold)
                .font(.largeTitle)
            Text(gameStatus)
            Spacer()
            
            TeamView(data: getDataForTeamScores(teamScores: playerScores), teamName: "Player", quater: gameQuarter)
            Spacer()
            TeamView(data: getDataForTeamScores(teamScores: cpuScores), teamName: "CPU", quater: gameQuarter)
            
            Spacer()
            Button(buttonLabel) {
                rollDice()
            }.padding()
                .foregroundColor(.white)
                .frame(width: 250.0, height: 50.0)
                .background(.blue)
                .clipShape(Capsule())

            Spacer()
        }
    }
    
    /// Button action function
    func rollDice() {
        switch gameQuarter {
        case 1, 2, 3, 4:
            generateScoreForTeam(teamScores: &playerScores, forQuarter: gameQuarter)
            generateScoreForTeam(teamScores: &cpuScores, forQuarter: gameQuarter)
            gameStatus = updateGameStatus()
            gameQuarter += 1
        default:
            playerScores = Array(repeating: (threes: 0, twos: 0), count: 4)
            cpuScores = Array(repeating: (threes: 0, twos: 0), count: 4)
            gameQuarter = 1
            gameStatus = updateGameStatus(inProgress: false)
        }
        
        buttonLabel = buttonLabels[gameQuarter - 1]
        
        func updateGameStatus(inProgress:Bool = true) -> String {
            
            guard inProgress else { return "Ready to Roll"}
            
            let playerTotalScore = getTotalScoreForGame(teamScores: playerScores)
            let cpuTotalScore = getTotalScoreForGame(teamScores: cpuScores)
            let scoreDiff = playerTotalScore - cpuTotalScore
            
            var isPlayerAhead:Bool { playerTotalScore > cpuTotalScore }
            var isCPUAhead:Bool { playerTotalScore < cpuTotalScore }
            
            var label = ""
            if isPlayerAhead {
                label = gameQuarter == 4 ? "Player wins by \(scoreDiff)" : "Player ahead by \(scoreDiff)"
            } else if isCPUAhead {
                label = gameQuarter == 4 ? "CPU wins by \(abs(scoreDiff))" : "CPU ahead by \(abs(scoreDiff))"
            } else {
                label = gameQuarter == 4 ? "It's a draw!!!" : "Scores level!!!"
            }
            
            return label
        }
        
    }
    
    /// Randomly generate score for a team
    func generateScoreForTeam(teamScores: inout [(threes:Int, twos:Int)], forQuarter quarter:Int) {
        teamScores[quarter - 1] = (threes: Int.random(in: 0...6), twos: Int.random(in: 0...6))
    }
    
    func getDataForTeamScores(teamScores:[(threes:Int, twos:Int)]) -> [[String]] {
        
        func getRowForTeamScores(teamScores:[(threes:Int, twos:Int)], forQuarter quater:Int) -> [String] {
            let q = teamScores[quater - 1]
            
            return [
                String(quater),
                String(q.threes),
                String(q.twos),
                String(getTotalScoreForQuater(teamScores: teamScores, forQuarter: quater))
            ]
        }
        
        let header = ["Quarter", "3pts", "2pts", "Total"]
        let quarter1 = getRowForTeamScores(teamScores: teamScores, forQuarter: 1)
        let quarter2 = getRowForTeamScores(teamScores: teamScores, forQuarter: 2)
        let quarter3 = getRowForTeamScores(teamScores: teamScores, forQuarter: 3)
        let quarter4 = getRowForTeamScores(teamScores: teamScores, forQuarter: 4)
        let footer = ["Score", "", "", String(getTotalScoreForGame(teamScores: teamScores))]
        
        /// Computer property
        var data:[[String]] {
            return [header, quarter1, quarter2, quarter3, quarter4, footer]
        }
        
        return data
    }
    
    /// Calculate the total points in a quater.
    func getTotalScoreForQuater(teamScores:[(threes:Int, twos:Int)], forQuarter quater:Int) -> Int {
        let q = teamScores[quater - 1]
        return q.threes * 3 + q.twos * 2
    }
    
    /// Calculate the total points in a game.
    func getTotalScoreForGame(teamScores:[(threes:Int, twos:Int)]) -> Int {
        return getTotalScoreForQuater(teamScores: teamScores, forQuarter: 1) +
            getTotalScoreForQuater(teamScores: teamScores, forQuarter: 2) +
            getTotalScoreForQuater(teamScores: teamScores, forQuarter: 3) +
            getTotalScoreForQuater(teamScores: teamScores, forQuarter: 4)
    }
}

/// Table view created with LazyVGrid
struct TeamView:View {
    var columns:[GridItem] = Array(repeating: GridItem(.flexible()), count: 4)
    let data:[[String]]
    let teamName:String
    let quater:Int
    
    var body: some View {
        VStack {
            Text(teamName).bold()
            LazyVGrid(columns: columns) {
                ForEach(0..<data.count, id: \.self) { i in
                    let row = data[i]
                    
                    let fontWeight:Font.Weight = i == 0 ? .bold : .regular
                    
                    let textHighlight:Color = i == (quater - 1) && i != 0 ? .blue : .black
                    
                    Text(row[0]).bold().foregroundColor(textHighlight)
                    Text(row[1]).fontWeight(fontWeight).foregroundColor(textHighlight)
                    Text(row[2]).fontWeight(fontWeight).foregroundColor(textHighlight)
                    Text(row[3]).bold().foregroundColor(textHighlight)
                }.padding(5)
            }
        }
    }
}

// Preview the ContentView
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

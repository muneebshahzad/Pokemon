//
//  ContentView.swift
//  Pokedex
//
//  Created by Michiel Spiritus on 13/03/2023.
//

import SwiftUI
import URLImage




struct ContentView: View {
    @State private var isAscending = true
    @State private var pokemon: [Pokemon] = []
    @State private var selectedItem: Pokemon?
    @Environment(\.presentationMode) var presentationMode
    @State private var isDetailViewPresented = false
    @StateObject  var favorites = Favorites()
    @StateObject  var team = Team()
    @State private var isTeamViewPresented = false
    @State private var isFavViewPresented = false
    @State private var searchText = ""
    @State private var pokemonList: pokemonList?
    
    func filterPokemon() -> [Pokemon] {
        if searchText.isEmpty {
            return pokemon
        } else {
            return pokemon.filter { $0.name.lowercased().contains(searchText.lowercased()) }
        }
    }
    
    var body: some View {
        
        VStack {
            HStack {
                Text("Pokédex")
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundColor(.black)
                    .padding(.leading)
                Spacer()
                HStack {
                    Button(action: {
                        // Filter actie hier
                    }, label: {
                        Image(systemName: "slider.horizontal.3")
                            .foregroundColor(.black)
                    })
                    Button(action: {
                        if isAscending {
                                               pokemon.sort(by: { $0.name < $1.name })
                                           } else {
                                               pokemon.sort(by: { $0.name > $1.name })
                                           }
                                           isAscending.toggle()

                    }, label: {
                        Image(systemName: "arrow.up.arrow.down")
                            .foregroundColor(.black)
                            .padding(.leading, 10)
                    })
                }
                .padding(.trailing)
            }
           
            SearchBar(searchText: $searchText, placeholder: "Pokemon zoeken")
                .padding(.horizontal)
           
            NavigationView {

                HStack {
                    NavigationView{
                        Button(action: {
                            isTeamViewPresented = true
                        }, label: {
                            SavedPokemonsView(title: "Mijn Team", subtitle: "\(team.pokemonsList.count) pokemons",image: Image("Rectangle 11"))
                        })
                        
                    }
                    .sheet(isPresented: $isTeamViewPresented) {
                        TeamListView(team: team)
                    }
                    

                    
                    
                    Button(action: {
                        isFavViewPresented = true

                        
                    }, label: {
                        SavedPokemonsView(title: "Favoriten", subtitle: "\(favorites.pokemonsList.count) pokemons",image: Image("Rectangle 11 copy"))
                    })
                    .sheet(isPresented: $isFavViewPresented) {
                        FavListView(team: favorites)
                    }
                }
               
                
                
            }
            
            .frame(height:100)
            
            
            
            VStack {
                
                if 1 != nil{ /*pokemonList = pokemonList {
                           ForEach(pokemonList.pokemon, id: \.id) { pokemon in
                               Text(pokemon.name)
                           }*/
                    
                    NavigationView {
                        
                        List(filterPokemon(), id: \.id) { pokemonItem in

                                       
                                       if pokemonItem.types.count > 1 {
                                           Button(action: {
                                                               selectedItem = pokemonItem
                                           }) {
                                               
                                               
                                                   SavedListView(title: pokemonItem.name, subtitle:
                                                                    String(pokemonItem.id),image: pokemonItem.sprites.frontDefault,type:pokemonItem.types[0].type.name,type2:pokemonItem.types[1].type.name)
                                               }}

                                       
                                       else {
                                           
                                           Button(action: {
                                                               selectedItem = pokemonItem
                                           }) {
                                               
                                               SavedListView(title: pokemonItem.name, subtitle:
                                                                String(pokemonItem.id),image: pokemonItem.sprites.frontDefault,type:pokemonItem.types[0].type.name,type2:nil)
                                               
                                           }

                                       }
                            
                            
                                   }
                               .onAppear {
                                   // Call the fetchPokemonList function when the view appears
                                   fetchPokemonList { pokemonList in
                                       // Update the @State variable with the fetched data
                                       pokemon = pokemonList
                                   }
                               }
                                   
                    }
                    .fullScreenCover(item: $selectedItem) { selectedItem in
                        NavigationView { clickedPokemonView(favorites: favorites, team: team, item: selectedItem)
                        
                        }
                        
                    }
                    

                       } else {
                           ProgressView()
                       }
                   }
                   .onAppear {
                    
                   }
            
            
        }
       
        
        
        
        
    }
    
}
struct SearchBar: View {
    @Binding var searchText: String
    var placeholder: String

    var body: some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .foregroundColor(.gray)
            TextField(placeholder, text: $searchText) // Use searchText instead of searchQuery
                .font(.body)
                .foregroundColor(.black)
                .padding(.vertical, 10)
            
            if !searchText.isEmpty {
                Button(action: {
                    self.searchText = ""
                }, label: {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.gray)
                        .padding(.trailing, 8)
                })
            }
        }
        .background(Color(.systemGray6))
        .cornerRadius(10)
    }
}
struct SavedPokemonsView: View {
    var title: String
    var subtitle: String
    var image: Image // Voeg deze regel toe
    
    var body: some View {
        ZStack {
            image // Gebruik de variabele image in plaats van de harde gecodeerde afbeelding
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: (UIScreen.main.bounds.width - 30) / 2, height: (UIScreen.main.bounds.width - 30) / 2) // Pas de grootte van de afbeelding aan
        VStack{
            Text(title)
                .font(.headline)
                .fontWeight(.bold)
                .foregroundColor(.white
                )
                .padding(.top)
            Text(subtitle)
                .font(.subheadline)
                .foregroundColor(.white)
                .padding(.bottom)
            
        }
        }
        
    }
}
struct SavedListView: View {
    @State private var pokemon: [Pokemon] = []
    
    var title: String
    var subtitle: String
    var image: String // Voeg deze regel toe
    var type: String
    var type2: String?
    
    @State private var searchText = ""
      

    var body: some View {
        VStack() {
            HStack() {
                URLImage(URL(string: image)!) { image in
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 60, height: 60)
                }
                
                VStack(alignment: .leading, spacing: 5) {
                    let firstLetter = title.prefix(1).uppercased()
                    let capitalizedString = firstLetter + title.dropFirst()
                    Text(capitalizedString)
                        .font(.headline)
                        .fontWeight(.bold)
                        .foregroundColor(.black)
                        .lineLimit(1)
                    
                    let number = Int(subtitle)
                    let formattedString = String(format: "No.%03d", number!)
                    Text(formattedString)
                        .font(.subheadline)
                        .foregroundColor(.gray)
                        .lineLimit(1)
                }
                .frame(width: 100)
                
                Spacer()
                HStack(spacing: 5) {
                    let firstLetter = type.prefix(1).uppercased()
                    let capitalizedString = firstLetter + type.dropFirst()
                    ZStack {
                        RoundedRectangle(cornerRadius: 10)
                            .fill(Color.blue)
                            .frame(height: 20)
                            .overlay(
                                GeometryReader { geo in
                                    Text(capitalizedString)
                                        .font(.subheadline)
                                        .foregroundColor(.white)
                                        .padding(.horizontal, 10)
                                        .lineLimit(1)
                                        .frame(width: geo.size.width)
                                }
                            )
                    }
                    if let type2 = type2 {
                        let firstLetter = type2.prefix(1).uppercased()
                        let capitalizedString = firstLetter + type2.dropFirst()
                        ZStack {
                            RoundedRectangle(cornerRadius: 10)
                                .fill(Color.blue)
                                .frame(height: 20)
                                .overlay(
                                    GeometryReader { geo in
                                        Text(capitalizedString)
                                            .font(.subheadline)
                                            .foregroundColor(.white)
                                            .padding(.horizontal, 10)
                                            .lineLimit(1)
                                            .frame(width: geo.size.width)
                                    }
                                )
                        }
                    }
                }
            }
            .padding()
            .background(Color.white)
            .cornerRadius(10)
        }
        .padding(.horizontal, -20)
    }
}





struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

struct clickedPokemonView: View {
    @State private var isFavorite = false
    @ObservedObject var favorites : Favorites
    @ObservedObject var team : Team
   
    
    
    
    let gradient = Gradient(colors: [
        Color(red: 199/255, green: 129/255, blue: 86/255),
        Color(red: 246/255, green: 224/255, blue: 195/255)
    ])
    
    let item: Pokemon
    
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        
        NavigationView {
            ZStack {
                
                LinearGradient(gradient: gradient, startPoint: .topLeading, endPoint: .bottomTrailing)
                    .edgesIgnoringSafeArea(.all)
                    .overlay(
                        URLImage(URL(string: item.sprites.frontDefault)!) { image in
                            image
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                        }
                    )
                
                VStack {
                    Spacer()
                    
                    if #available(iOS 16.0, *) {
                        Button(action: {
                            if !team.pokemonsList.contains(where: { $0.id == item.id }) {
                                team.add(item)
                                print("item Added, total items \(team.pokemonsList.count) \(team.pokemonsList[team.pokemonsList.count-1].name) ")
                            } else {
                                print("item already exists in team")
                            }
                        }) {
                            Text("Add to Team")
                        }
                        .frame(minWidth: 0, maxWidth: .infinity)
                        .fontWeight(.semibold)
                        .padding()
                        .foregroundColor(.white)
                        .background(Color.black)
                        .cornerRadius(40)
                        .padding()
                    } else {
                        // Fallback on earlier versions
                    }
                }
                
                .navigationBarBackButtonHidden(true)
                .toolbar {
                    ToolbarItem(placement: .navigationBarLeading) {
                        Button(action: {
                            presentationMode.wrappedValue.dismiss()
                        }) {
                            Image(systemName: "chevron.left")
                            Text("Back")
                        }
                        .foregroundColor(.white)
                    }
                }
                .navigationBarItems(trailing:
                                     
                    Button(action: {
                    if !favorites.pokemonsList.contains(where: { $0.id == item.id }) {
                            favorites.add(item)
                            print("item Added, total items \(favorites.pokemonsList.count) \(favorites.pokemonsList[favorites.pokemonsList.count-1].name) ")
                            isFavorite.toggle()
                        } else {
                            print("item already exists in favorites")
                        }
                    }) {
                        Image(systemName: isFavorite ? "heart.fill" : "heart")
                    }
                )
                .accentColor(.white)
                .navigationBarTitleDisplayMode(.automatic)
            }
        }
        .navigationTitle(item.name.prefix(1).uppercased() + item.name.dropFirst())
    }
}


struct TeamListView: View {
    @Environment(\.presentationMode) var presentationMode
    @StateObject var team: Team
    
    var body: some View {
        NavigationView {
            
            List(team.pokemonsList) { pokemon in
                HStack{
                    
                    URLImage(URL(string: pokemon.sprites.frontDefault)!) { image in
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                    }
                    .frame(width: 80)
                    
                    
                    HStack{
                        VStack{
                            
                            let firstLetter = pokemon.name.prefix(1).uppercased()
                            let capitalizedString = firstLetter + pokemon.name.dropFirst()
                            Text(capitalizedString)
                                .font(.headline)
                                .fontWeight(.bold)
                                .foregroundColor(.black
                                )
                                .padding(.top)
                            let number = Int(pokemon.id)
                            let formattedString = String(format: "No.%03d", number)
                            
                            Text(formattedString)
                                .font(.subheadline)
                                .foregroundColor(.black)
                                .padding(.bottom)
                            
                            
                                .frame(width: 110)
                        }
                        let myHexColor = Color(red:66 / 255, green: 197 / 255, blue: 245 / 255)
                        
                        HStack{
                            let firstLetter = pokemon.types[0].type.name.prefix(1).uppercased()
                            let capitalizedString = firstLetter + pokemon.types[0].type.name.dropFirst()
                            ZStack {
                                RoundedRectangle(cornerRadius: 10)
                                    .fill(myHexColor)
                                    .frame(height: 20)
                                
                                Text(capitalizedString)
                                    .font(.subheadline)
                                    .foregroundColor(Color.white)
                                    .padding(.horizontal, 10)
                                
                                
                            }
                            
                            if pokemon.types.count > 1 {
                                
                                ZStack {
                                    RoundedRectangle(cornerRadius: 10)
                                        .fill(myHexColor)
                                        .frame(height: 20)
                                    Text(pokemon.types[1].type.name.prefix(1).uppercased() + pokemon.types[1].type.name.dropFirst())
                                    
                                        .font(.subheadline)
                                        .foregroundColor(.white)
                                        .padding(.horizontal, 10)
                                }
                                
                                
                            }
                            
                            else {
                                ZStack {
                                    RoundedRectangle(cornerRadius: 10)
                                        .fill(Color.white)
                                        .frame(height: 20)
                                    
                                }
                                
                            }
                            
                            
                        }
                        .frame(width: 160)
                        .multilineTextAlignment(.trailing)
                        
                        
                        
                    }
                    
                    
                }
                .navigationBarTitle("Mijn Team")
                .navigationBarItems(trailing: Button(action: {
                    presentationMode.wrappedValue.dismiss()
                }, label: {
                    Text("Sluiten")
                }))
            }}
    }}





struct FavListView: View {
    @Environment(\.presentationMode) var presentationMode
    @StateObject var team: Favorites
    
    var body: some View {
        
        
        NavigationView {
            
            List(team.pokemonsList) { pokemon in
                HStack{
                    
                    URLImage(URL(string: pokemon.sprites.frontDefault)!) { image in
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                    }
                    .frame(width: 80)
                    
                    
                    HStack{
                        VStack{
                            
                            let firstLetter = pokemon.name.prefix(1).uppercased()
                            let capitalizedString = firstLetter + pokemon.name.dropFirst()
                            Text(capitalizedString)
                                .font(.headline)
                                .fontWeight(.bold)
                                .foregroundColor(.black
                                )
                                .padding(.top)
                            let number = Int(pokemon.id)
                            let formattedString = String(format: "No.%03d", number)
                            
                            Text(formattedString)
                                .font(.subheadline)
                                .foregroundColor(.black)
                                .padding(.bottom)
                            
                            
                                .frame(width: 110)
                        }
                        let myHexColor = Color(red:66 / 255, green: 197 / 255, blue: 245 / 255)
                        
                        HStack{
                            let firstLetter = pokemon.types[0].type.name.prefix(1).uppercased()
                            let capitalizedString = firstLetter + pokemon.types[0].type.name.dropFirst()
                            ZStack {
                                RoundedRectangle(cornerRadius: 10)
                                    .fill(myHexColor)
                                    .frame(height: 20)
                                
                                Text(capitalizedString)
                                    .font(.subheadline)
                                    .foregroundColor(Color.white)
                                    .padding(.horizontal, 10)
                                
                                
                            }
                            
                            if pokemon.types.count > 1 {
                                
                                ZStack {
                                    RoundedRectangle(cornerRadius: 10)
                                        .fill(myHexColor)
                                        .frame(height: 20)
                                    Text(pokemon.types[1].type.name.prefix(1).uppercased() + pokemon.types[1].type.name.dropFirst())
                                    
                                        .font(.subheadline)
                                        .foregroundColor(.white)
                                        .padding(.horizontal, 10)
                                }
                                
                                
                            }
                            
                            else {
                                ZStack {
                                    RoundedRectangle(cornerRadius: 10)
                                        .fill(Color.white)
                                        .frame(height: 20)
                                    
                                }
                                
                            }
                            
                            
                        }
                        .frame(width: 160)
                        .multilineTextAlignment(.trailing)
                        
                        
                        
                    }
                    
                    
                }
                
                .navigationBarTitle("Favoriten")
                .navigationBarItems(trailing: Button(action: {
                    presentationMode.wrappedValue.dismiss()
                }, label: {
                    Text("Sluiten")
                }))
            }
            
        }
        
    }
}

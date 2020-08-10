//
//  ContentView.swift
//  Subscriptor
//
//  Created by Robert Fish on 9/8/20.
//

import SwiftUI
import Amplify
import AmplifyPlugins
import Combine

struct ContentView: View {
    
    @State var subscriptions = [Service]()
    @State var showAddSubscription: Bool = false
    @State var observationToken: AnyCancellable?
    
    var categories = ["Business", "Education", "Developer Tools", "Entertainment", "Finance", "Games", "Graphics & Design", "Health & Fitnes", "Lifestyle", "Medical", "Music", "News", "Photo & Video", "Productivity", "Social Networking", "Sports", "Travel", "Utilities"]
    
    // Form Fields
    @State var name: String = ""
    @State var price: String = ""
    @State var purchaseDate = Date()
    @State var category = 0
    //
    
    @State var mapChoioce = 0
    var settings = ["Map", "Transit", "Satellite"]
    
    init() {
        configureAmplify()
    }
    var body: some View {
        NavigationView {
            List{
                ForEach(subscriptions){ subscription in
                    Text(subscription.title)
                }.onDelete(perform: deleteSubscription)
            }.navigationTitle("Subscriptions").navigationBarItems(trailing: Button(action: {
                showAddSubscription.toggle()
            }){
                Image(systemName: "plus.circle.fill")
            })
        }.onAppear(perform: {
            getSubscriptions()
            observeSubscriptions()
        }).sheet(isPresented: $showAddSubscription){
            NavigationView{
                Form{
                    Section(header: Text("Name")){
                        TextField("Netflix", text: $name)
                    }
                    Section(header: Text("Price")){
                        TextField("$10.00", text: $price)
                            .keyboardType(.numberPad)
                    }
                    Section {
                        Picker(selection: $category, label: Text("Options")) {
                            ForEach(0 ..< categories.count) {
                                Text(categories[$0])
                            }
                            Text(self.categories[category])
                        }
                    }
                    Section(header: Text("Purchase Date")){
                        DatePicker("", selection: $purchaseDate, displayedComponents: .date)
                    }
                    Button(action: {
                        let formatter = DateFormatter()
                        formatter.dateStyle = .long
                        let subscription = Service(title: self.name, price: Double(self.price) ?? 0, category: categories[category], purchaseDate: formatter.string(from: self.purchaseDate))
                        Amplify.DataStore.save(subscription){result in
                            switch result{
                            case .success:
                                print("saved subscription")
                            case .failure(let error):
                                print(error)
                            }
                        }
                        self.showAddSubscription.toggle()
                    }){
                        Text("Submit")
                    }
                }.navigationTitle("Create Subscription")
            }.padding()
            
        }
    }
    
    func observeSubscriptions(){
        observationToken = Amplify.DataStore.publisher(for: Service.self).sink(receiveCompletion: { completion in
            if case .failure(let error) = completion {
                print(error)
            }
        }, receiveValue: { changes in
            guard let subscription = try? changes.decodeModel(as: Service.self) else {return}
            
            switch changes.mutationType {
            case "create":
                self.subscriptions.append(subscription)
            case "delete":
                if let index = self.subscriptions.firstIndex(where: { $0.id == subscription.id}){
                    self.subscriptions.remove(at: index)
                }
            default:
                break
            }
        })
    }
    
    func getSubscriptions(){
        Amplify.DataStore.query(Service.self) {result in
            switch result {
            case .success(let subscriptions):
                print(subscriptions)
                self.subscriptions = subscriptions
                
            case .failure(let error):
                print(error)
            }
        }
    }
    
    func deleteSubscription(at indexSet: IndexSet){
        var updatedSubscriptions = subscriptions
        updatedSubscriptions.remove(atOffsets: indexSet)
        guard let subscription = Set(updatedSubscriptions).symmetricDifference(subscriptions).first  else {return}
        
        Amplify.DataStore.delete(subscription){result in
            switch result {
            case .success:
                print("deleted subscription")
            case .failure(let error):
                print("failed to delete subscription - \(error)")
            }
        }
    }
    
    func configureAmplify(){
        do {
            try Amplify.add(plugin: AWSDataStorePlugin(modelRegistration: AmplifyModels()))
            try Amplify.configure()
            print("Amplify initialised")
        }
        catch{
            print("could not initialise amplify - \(error)")
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .preferredColorScheme(.dark)
    }
}

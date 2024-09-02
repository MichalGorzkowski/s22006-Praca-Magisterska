//
//  FirebaseManager.swift
//  Board Game Center
//
//  Created by Michał Gorzkowski on 04/01/2024.
//

import Firebase
import FirebaseStorage
import FirebaseCore
import FirebaseFirestore

class FirebaseManager: ObservableObject {
    let auth = Auth.auth()
    let storage = Storage.storage()
    let db = Firestore.firestore()
    
    @Published var user: User = User(id: "id", firstName: "firstName", lastName: "lastName", email: "email", photoURL: "photoURL")
    @Published var loggedIn = false
    @Published var isRegistrationViewActive = false
    @Published var setsInCollectionList = [LegoSet]()
    
    var isLoggedIn: Bool {
        return auth.currentUser != nil
    }
    
    func signIn(email: String, password: String) {
        auth.signIn(withEmail: email,
                    password: password) { [weak self] result, error in
            guard result != nil, error == nil else {
                return
            }
            
            DispatchQueue.main.async {
                self?.loggedIn = true
            }
            
            print("DEBUG: user \(String(describing: self?.auth.currentUser?.uid)) signed in successfully")
        }
    }
    
    func signUp(firstName: String, lastName: String, email: String, password: String, image: UIImage?) {
        auth.createUser(withEmail: email,
                        password: password) { [weak self] result, error in
            guard result != nil, error == nil else {
                return
            }
            
            DispatchQueue.main.async {
                self?.loggedIn = true
            }
            
            print("DEBUG: user \(String(describing: self?.auth.currentUser?.uid)) signed up successfully")
            
            self?.saveProfileInfoInFirebase(firstName: firstName, lastName: lastName, email: email, image: image ?? UIImage(resource: .minifigure))
        }
    }
    
    func signOut() {
        try? auth.signOut()
        
        self.loggedIn = false
        
        print("DEBUG: user signed out successfully")
    }
    
    func switchView() {
        DispatchQueue.main.async {
            self.isRegistrationViewActive = !self.isRegistrationViewActive
            print("DEBUG: isRegistrationViewActive: ", self.isRegistrationViewActive)
        }
    }
    
    private func saveProfileInfoInFirebase(firstName: String, lastName: String, email: String, image: UIImage) {
        guard let uid = auth.currentUser?.uid else { return }
        let ref = storage.reference().child("profileImages/\(uid)")
        var photoUrl: String = ""
        
        guard let imageData = image.jpegData(compressionQuality: 0.5) else { return }
        
        ref.putData(imageData, metadata: nil) { metadata, error in
            if let error = error {
                print("DEBUG: Failed to push image to storage: \(error)")
                return
            }
            
            ref.downloadURL { url, error in
                if let error = error {
                    print("DEBUG: Failed to retrieve downloadURL: \(error)")
                    return
                }
                
                photoUrl = url?.absoluteString ?? ""
                
                print("DEBUG: Image stored successfully with url: \(url?.absoluteString ?? "")")
            }
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            self.db.collection("users").document(uid).setData([
                "uid": uid,
                "firstName": firstName,
                "lastName": lastName,
                "email": email,
                "photoURL": photoUrl
            ])
        }
    }
    
    func getUserDataFromFirebase() {
        let userRef = db.collection("users").document(auth.currentUser?.uid ?? "")
        
        userRef.getDocument { (document, error) in
            guard error == nil else {
                print("ERROR: ", error ?? "")
                return
            }

            if let document = document, document.exists {
                let data = document.data()
                if let data = data {
                    //print("data", data)
                    self.user.id = data["uid"] as? String ?? ""
                    self.user.firstName = data["firstName"] as? String ?? ""
                    self.user.lastName = data["lastName"] as? String ?? ""
                    self.user.email = data["email"] as? String ?? ""
                    self.user.photoURL = data["photoURL"] as? String ?? ""

                }
            }
        }
    }
    
    func addSetToCollection(legoSet: LegoSet) {
        guard let uid = auth.currentUser?.uid else { return }
        
        self.db.collection("users").document(uid).collection("sets").document(legoSet.setNum).setData([
            "setNum": legoSet.setNum,
            "name": legoSet.name,
            "year": legoSet.year,
            "themeId": legoSet.themeId,
            "numParts": legoSet.numParts,
            "setImgURL": legoSet.setImgURL?.absoluteString,
            "setURL": legoSet.setURL.absoluteString,
            "lastModifiedDt": legoSet.lastModifiedDt
        ])
    }
    
    func removeSetFromCollection(legoSet: LegoSet) {
        guard let uid = auth.currentUser?.uid else { return }
        
        db.collection("users").document(uid).collection("sets").document(legoSet.setNum).delete() { error in
            if let error = error {
                print("DEBUG: Error removing document: \(error)")
            } else {
                print("DEBUG: Document successfully removed!")
                self.getUserSetCollectionListFromFirebase() // Odświeża listę po usunięciu
            }
        }
    }
    
    func getUserSetCollectionListFromFirebase() {
        let userRef = db.collection("users").document(auth.currentUser?.uid ?? "").collection("sets")
        
        userRef.getDocuments() { snapshot, error in
            if error == nil {
                if let snapshot = snapshot {
                    
                    DispatchQueue.main.async {
                        self.setsInCollectionList = snapshot.documents.map { d in
                            
                            let string1 = d["setImgURL"] as? String ?? ""
                            let string2 = d["setURL"] as? String ?? ""
                            
                            return LegoSet(setNum: d["setNum"] as? String ?? "error",
                                           name: d["name"] as? String ?? "error",
                                           year: d["year"] as? Int ?? -1,
                                           themeId: d["themeId"] as? Int ?? -1,
                                           numParts: d["numParts"] as? Int ?? -1,
                                           setImgURL: URL(string: string1) ?? URL(string: "error")!,
                                           setURL: (URL(string: string2) ?? URL(string: "error"))!,
                                           lastModifiedDt: d["lastModifiedDt"] as? String ?? "error")
                            
                        }
                    }
                }
            } else {
                
            }
        }
    }
    
    /*
    func saveUserInteraction(interaction: UserInteraction) {
        guard let uid = auth.currentUser?.uid else { return }
        
        let interactionData: [String: Any] = [
            "userId": interaction.userId,
            "setId": interaction.setId,
            "interactionScore": interaction.interactionScore,
            "timestamp": interaction.timestamp
        ]
        
        db.collection("users").document(uid).collection("interactions").addDocument(data: interactionData) { error in
            if let error = error {
                print("DEBUG: Error saving interaction: \(error)")
            } else {
                print("DEBUG: Interaction saved successfully")
            }
        }
    }
    
    func getUserInteractions(userId: String, completion: @escaping ([UserInteraction]) -> Void) {
        db.collection("users").document(userId).collection("interactions").getDocuments { snapshot, error in
            guard error == nil, let documents = snapshot?.documents else {
                print("DEBUG: Error retrieving interactions: \(error?.localizedDescription ?? "Unknown error")")
                completion([])
                return
            }
            
            let interactions: [UserInteraction] = documents.compactMap { doc in
                let data = doc.data()
                guard
                    let setId = data["setId"] as? String,
                    let interactionScore = data["interactionScore"] as? Double,
                    let timestamp = (data["timestamp"] as? Timestamp)?.dateValue() else {
                    return nil
                }
                
                return UserInteraction(userId: userId, setId: setId, interactionScore: interactionScore, timestamp: timestamp)
            }
            
            completion(interactions)
        }
    }
     */
}

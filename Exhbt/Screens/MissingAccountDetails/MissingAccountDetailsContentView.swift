//
//  MissingAccountDetailsContentView.swift
//  Exhbt
//
//  Created by Mehmet Tarhan on 03/09/2023.
//  Copyright © 2023 Exhbt LLC. All rights reserved.
//

import SwiftUI

struct MissingAccountDetailsEntries {
    let fullName: String?
    let username: String
    let bio: String?
}

struct MissingAccountDetailsContentView: View {
    @State var fullName = ""
    @State var username = ""
    @State var bio = ""

    enum Field {
        case prompt
    }

    @FocusState var focus: Field?

    var didFinishEditing: ((_ entries: MissingAccountDetailsEntries) -> Void)?

    init(didFinishEditing: ((_: MissingAccountDetailsEntries) -> Void)? = nil) {
        self.didFinishEditing = didFinishEditing
    }

    var body: some View {
        VStack(spacing: 24) {
            VStack(alignment: .leading, spacing: 2) {
                VStack(alignment: .leading, spacing: 2) {
                    Text("Username")
                        .foregroundColor(.blue)
                        .font(.system(size: 14).weight(.semibold))
                    TextField("Enter your username", text: $username, onCommit: {
                        self.didFinishEditing?(MissingAccountDetailsEntries(fullName: fullName, username: username, bio: bio != "" ? bio : nil))

                    })
                    .padding(.vertical, 4)
                    .focused($focus, equals: .prompt)
                    .keyboardType(.namePhonePad)
                    Divider()
                    Text("Required")
                        .font(.footnote)
                }

                Text("Full Name")
                    .foregroundColor(.blue)
                    .font(.system(size: 14).weight(.semibold))
                TextField("Enter your full name", text: $fullName, onCommit: {
                    self.didFinishEditing?(MissingAccountDetailsEntries(fullName: fullName != "" ? fullName : nil, username: username, bio: bio != "" ? bio : nil))

                })
                .padding(.vertical, 4)
                .focused($focus, equals: .prompt)
                Divider()
                Text("Optional")
                    .font(.footnote)
            }

            VStack(alignment: .leading, spacing: 2) {
                Text("Bio")
                    .foregroundColor(.blue)
                    .font(.system(size: 14).weight(.semibold))
                TextField("Enter your bio", text: $bio, axis: .vertical)
                    .padding(.vertical, 4)
                    .focused($focus, equals: .prompt)
                    .submitLabel(.return) // <- change to return
                    .toolbar { // adding the toolbar
                        ToolbarItemGroup(placement: .keyboard) {
                            Spacer()
                            Button("Done") {
                                focus = nil
                                self.didFinishEditing?(MissingAccountDetailsEntries(fullName: fullName, username: username, bio: bio != "" ? bio : nil))
                            }
                        }
                    }
                    .foregroundColor(.blue)
                Divider()
                Text("Optional")
                    .font(.footnote)
            }

            Spacer()
        }
        .padding(.horizontal, 24)
    }
}

struct MissingAccountDetailsContentView_Previews: PreviewProvider {
    static var previews: some View {
        MissingAccountDetailsContentView()
    }
}

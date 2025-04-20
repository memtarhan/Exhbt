//
//  NewExhbtSetupContentView.swift
//  Exhbt
//
//  Created by Mehmet Tarhan on 06/08/2023.
//  Copyright © 2023 Exhbt LLC. All rights reserved.
//

import SwiftUI
import UIKit

protocol NewExhbtSetupDelegate {
    func newExhbtSetup(didSelecTags tags: [String], description: String?)
}

class TagDisplayModel: DisplayModel, Identifiable {
    let title: String

    init(id: Int, title: String) {
        self.title = title
        super.init(id: id)
    }
}

class TagsDisplayModel: DisplayModel {
    let tags: [TagDisplayModel]

    init(id: Int, tags: [TagDisplayModel]) {
        self.tags = tags
        super.init(id: id)
    }
}

struct TagModel: Hashable {
    let title: String
}

let sampleTags = [TagModel(title: "#fun"),
                  TagModel(title: "#nature")]

struct NewExhbtSetupContentView: View {
    var image: UIImage

    @State private var enteredTitle: Bool = false
    @State private var searchedKeyword: String = ""
    @State var tags: [TagModel] = []

    var delegate: NewExhbtSetupDelegate?

    var body: some View {
        GeometryReader { geometry in
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    NewExhbtMediaView(image: image, width: geometry.size.width / 4)
                        .padding(.horizontal, 16)

                    NewExhbtTagsView(delegate: delegate)
                }
            }
        }
    }
}

struct NewExhbtMediaView: View {
    var image: UIImage
    var width: CGFloat

    var body: some View {
        VStack(alignment: .leading) {
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.green)
                    Text("Add Photo/Video")
                        .font(.system(size: 18, weight: .medium))
                }
                Text("Photo/Video to create this Exhbt")
                    .font(.system(size: 15, weight: .regular))
            }

            HStack {
                Spacer()
                Image(uiImage: image)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: width, height: width * 1.5)
                    .cornerRadius(12)
                Spacer()
            }
        }
    }
}

struct NewExhbtTitleView: View {
    @Binding var exhbtTitle: String
    @Binding var enteredTitle: Bool

    var delegate: NewExhbtSetupDelegate?

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: enteredTitle ? "checkmark.circle.fill" : "2.circle")
                    .foregroundColor(enteredTitle ? .green : .black)
                Text("Exhbt Title (Optional)")
                    .font(.system(size: 18, weight: .medium))
            }

            VStack(alignment: .leading) {
                TextField("Enter your title", text: $exhbtTitle, onCommit: {
                    enteredTitle = exhbtTitle != ""
                })
                .autocorrectionDisabled()
                Divider()
            }
        }
    }
}

struct NewExhbtTagsView: View {
    enum Field {
        case prompt
    }

    @State private var description = ""
    @FocusState private var focus: Field?

    var delegate: NewExhbtSetupDelegate?

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Image(systemName: description.isEmpty ? "2.circle" : "checkmark.circle.fill")
                        .foregroundColor(description.isEmpty ? .black : .green)
                    Text("Add Description")
                        .font(.system(size: 18, weight: .medium))
                }

                HStack {
                    Text("Description ")
                        .font(.system(size: 15, weight: .regular))
                    Spacer()
                    Text("\(description.count)/180")
                        .font(.system(size: 15, weight: .regular))
                }
            }
            .padding(.horizontal, 16)

            VStack(alignment: .leading) {
                ZStack(alignment: .leading) {
                    textWithHashtags(description, color: .blue)
                        .lineLimit(4)

                    ZStack(alignment: .top) {
                        TextField("Enter your description", text: $description.max(180), axis: .vertical)
                            .lineLimit(4)
                            .tint(.blue)
                            .foregroundStyle(Color.black)
                            .autocorrectionDisabled()
                            .padding(.vertical, 8)
                            .padding(.horizontal, 6)
                            .background(Color(uiColor: .textBoxBackgroundColor))
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                            .focused($focus, equals: .prompt)
                            .toolbar {
                                ToolbarItemGroup(placement: .keyboard) {
                                    Spacer()
                                    Button("Done") {
                                        focus = nil
                                        if !description.isEmpty {
                                            let tags = description.hashtags()
                                            debugLog(self, tags)
                                            delegate?.newExhbtSetup(didSelecTags: tags, description: description)
                                        }
                                    }
                                    .tint(.blue)
                                }
                            }

                        VStack {
                        }
                        .background(Color(uiColor: .textBoxBackgroundColor))
                        .frame(height: 100)
                    }
                    .background(Color(uiColor: .textBoxBackgroundColor))
                    .frame(height: 100)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                }
                .padding(.horizontal, 16)
            }
        }
    }

    func textWithHashtags(_ text: String, color: Color) -> Text {
        let words = text.split(separator: " ")
        var output: Text = Text("")

        for word in words {
            if word.hasPrefix("#") { // Pick out hash in words
                output = output + Text(" ") + Text(String(word))
                    .foregroundColor(color) // Add custom styling here
            } else {
                output = output + Text(" ") + Text(String(word))
                    .foregroundColor(Color.black)
            }
        }
        return output
    }
}

struct NewExhbtSetupContentView_Previews: PreviewProvider {
    static var previews: some View {
        NewExhbtSetupContentView(image: UIImage(named: "BeautyCategory")!)
    }
}

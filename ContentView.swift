//
//  ContentView.swift
//  MirimTimeTable
//
//  Created by justcallmelight_ on 3/25/26.
//

import SwiftUI
import WebKit

struct ContentView: View {
    var body: some View {
        MirimTimeTableWebContainer()
            .ignoresSafeArea()
    }
}

private struct MirimTimeTableWebContainer: View {
    var body: some View {
        Group {
            if MirimTimeTableWebRepresentable.mainHTMLURL != nil {
                MirimTimeTableWebView()
            } else {
                VStack(spacing: 12) {
                    Image(systemName: "calendar.badge.clock")
                        .font(.system(size: 44, weight: .semibold))
                        .foregroundStyle(.secondary)

                    Text("MirimTimeTable 웹 파일을 앱 번들에 추가해야 합니다.")
                        .font(.headline)

                    Text("Xcode에서 index.html, style.css, script.js를 프로젝트에 넣고 Target Membership을 체크하면, 웹 버전과 같은 UI로 앱에서 실행됩니다.")
                        .font(.subheadline)
                        .multilineTextAlignment(.center)
                        .foregroundStyle(.secondary)
                        .padding(.horizontal, 24)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(Color(.systemBackground))
            }
        }
    }
}

private struct MirimTimeTableWebView: View {
    var body: some View {
        MirimTimeTableWebRepresentable()
            .ignoresSafeArea()
            .background(Color.clear)
    }
}

#if os(iOS)
private struct MirimTimeTableWebRepresentable: UIViewRepresentable {
    func makeUIView(context: Context) -> WKWebView {
        let configuration = WKWebViewConfiguration()
        configuration.defaultWebpagePreferences.allowsContentJavaScript = true

        let webView = WKWebView(frame: .zero, configuration: configuration)
        webView.scrollView.contentInsetAdjustmentBehavior = .never
        webView.isOpaque = false
        webView.backgroundColor = .clear
        webView.scrollView.backgroundColor = .clear
        webView.navigationDelegate = context.coordinator
        loadHTML(into: webView)
        return webView
    }

    func updateUIView(_ webView: WKWebView, context: Context) {
        if webView.url == nil {
            loadHTML(into: webView)
        }
    }

    func makeCoordinator() -> Coordinator {
        Coordinator()
    }
}
#elseif os(macOS)
private struct MirimTimeTableWebRepresentable: NSViewRepresentable {
    func makeNSView(context: Context) -> WKWebView {
        let configuration = WKWebViewConfiguration()
        configuration.defaultWebpagePreferences.allowsContentJavaScript = true

        let webView = WKWebView(frame: .zero, configuration: configuration)
        webView.setValue(false, forKey: "drawsBackground")
        webView.navigationDelegate = context.coordinator
        loadHTML(into: webView)
        return webView
    }

    func updateNSView(_ webView: WKWebView, context: Context) {
        if webView.url == nil {
            loadHTML(into: webView)
        }
    }

    func makeCoordinator() -> Coordinator {
        Coordinator()
    }
}
#endif

private extension MirimTimeTableWebRepresentable {
    static var mainHTMLURL: URL? {
        Bundle.main.url(forResource: "index", withExtension: "html")
        ?? Bundle.main.url(forResource: "MirimTimeTable", withExtension: "html")
    }

    func loadHTML(into webView: WKWebView) {
        guard let htmlURL = Self.mainHTMLURL else {
            return
        }

        let folderURL = htmlURL.deletingLastPathComponent()
        webView.loadFileURL(htmlURL, allowingReadAccessTo: folderURL)
    }

    final class Coordinator: NSObject, WKNavigationDelegate {
    }
}

#Preview {
    ContentView()
}

#!/usr/bin/env python3
import base64
import json
import requests
import sys
import time

# Azureの設定（実際の値を入力してください）
AZURE_SPEECH_KEY = input("Azure Speech APIキーを入力してください: ")
AZURE_SPEECH_REGION = input("Azure Speech リージョンを入力してください (デフォルト: japaneast): ") or "japaneast"

# テスト用の音声ファイル
AUDIO_FILE_PATH = "/Users/yamazakishohei/Documents/SOZO/coral_gpt-4o-mini-tts_1x_2025-06-17T10_53_35-183Z.wav"
EXPECTED_TEXT = "good morning! would you like to do a treatment as well"

def test_pronunciation_assessment():
    # APIエンドポイント
    base_url = f"https://{AZURE_SPEECH_REGION}.stt.speech.microsoft.com"
    url = f"{base_url}/speech/recognition/conversation/cognitiveservices/v1?language=en-US&format=detailed"
    
    # 発音評価のパラメータ
    pronunciation_config = {
        "referenceText": EXPECTED_TEXT,
        "gradingSystem": "HundredMark",
        "dimension": "Comprehensive",
        "enableMiscue": True,
        "phonemeAlphabet": "IPA"
    }
    
    # Base64エンコード
    pronunciation_header = base64.b64encode(
        json.dumps(pronunciation_config).encode('utf-8')
    ).decode('utf-8')
    
    # 音声ファイルを読み込む
    try:
        with open(AUDIO_FILE_PATH, 'rb') as audio_file:
            audio_data = audio_file.read()
    except FileNotFoundError:
        print(f"エラー: 音声ファイルが見つかりません: {AUDIO_FILE_PATH}")
        return
    
    # HTTPヘッダー
    headers = {
        'Ocp-Apim-Subscription-Key': AZURE_SPEECH_KEY,
        'Content-Type': 'audio/wav',
        'Accept': 'application/json',
        'Pronunciation-Assessment': pronunciation_header
    }
    
    print("\nAzure Speech APIにリクエストを送信中...")
    print(f"URL: {url}")
    print(f"音声ファイル: {AUDIO_FILE_PATH}")
    print(f"期待されるテキスト: {EXPECTED_TEXT}")
    
    # APIリクエスト
    start_time = time.time()
    try:
        response = requests.post(url, headers=headers, data=audio_data, timeout=30)
        elapsed_time = time.time() - start_time
        print(f"\nレスポンス時間: {elapsed_time:.2f}秒")
        print(f"ステータスコード: {response.status_code}")
        
        if response.status_code == 200:
            result = response.json()
            print("\n✅ 発音評価結果:")
            
            if 'NBest' in result and len(result['NBest']) > 0:
                best_result = result['NBest'][0]
                
                # 基本情報
                print(f"認識されたテキスト: {best_result.get('Lexical', '')}")
                print(f"表示テキスト: {best_result.get('Display', '')}")
                print(f"信頼度: {best_result.get('Confidence', 0):.2f}")
                
                # スコア
                print(f"\n発音スコア: {best_result.get('PronScore', 0):.1f}/100")
                print(f"正確性スコア: {best_result.get('AccuracyScore', 0):.1f}/100")
                print(f"流暢性スコア: {best_result.get('FluencyScore', 0):.1f}/100")
                print(f"完全性スコア: {best_result.get('CompletenessScore', 0):.1f}/100")
                
                # 単語レベルのスコア
                if 'Words' in best_result:
                    print("\n単語レベルのスコア:")
                    for word in best_result['Words']:
                        error_type = word.get('ErrorType', 'None')
                        accuracy = word.get('AccuracyScore', 0)
                        print(f"  {word.get('Word', '')}: {accuracy:.1f}/100 ({error_type})")
                
                # 完全なレスポンスをファイルに保存
                with open('azure_pronunciation_result.json', 'w') as f:
                    json.dump(result, f, indent=2)
                print("\n完全なレスポンスが azure_pronunciation_result.json に保存されました")
            else:
                print("エラー: 認識結果が見つかりません")
                print(f"レスポンス: {json.dumps(result, indent=2)}")
        else:
            print(f"\n❌ エラー: {response.status_code}")
            print(f"エラーメッセージ: {response.text}")
            
            try:
                error_json = response.json()
                if 'error' in error_json:
                    print(f"エラー詳細: {error_json['error'].get('message', 'Unknown error')}")
            except:
                pass
                
    except requests.exceptions.Timeout:
        print("❌ エラー: リクエストがタイムアウトしました")
    except requests.exceptions.RequestException as e:
        print(f"❌ エラー: {e}")
    except Exception as e:
        print(f"❌ 予期しないエラー: {e}")

if __name__ == "__main__":
    print("Azure Speech Service 発音評価テスト")
    print("=" * 50)
    
    if not AZURE_SPEECH_KEY:
        print("エラー: Azure Speech APIキーが設定されていません")
        sys.exit(1)
    
    test_pronunciation_assessment() 
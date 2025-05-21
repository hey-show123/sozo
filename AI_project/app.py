from flask import Flask, render_template, jsonify, request, session
import os
from dotenv import load_dotenv
import openai
import json
import uuid
import sys

# ファイルパスの設定
LESSON_CONTENT_FILE = "AI_project/lesson_content.json"

# Flaskアプリケーションの初期化
app = Flask(__name__, template_folder='templates')
app.secret_key = os.urandom(24)  # セッション管理用のシークレットキー

# 環境変数の読み込み
load_dotenv()
print("環境変数を読み込みました")

# OpenAI APIキーの取得
openai_api_key = os.getenv("OPENAI_API_KEY")
print(f"OpenAI APIキー: {'設定されています' if openai_api_key else '設定されていません'}")

# OpenAIクライアントの初期化
openai_client = None
if openai_api_key:
    try:
        openai_client = openai.OpenAI(api_key=openai_api_key)
        print("OpenAI クライアントの初期化に成功しました")
    except Exception as e:
        print(f"OpenAI クライアントの初期化中にエラーが発生しました: {e}")
else:
    print("警告: OPENAI_API_KEYが見つかりません。APIキーを設定してください。")
    print("モックAPIモードを有効にします。APIレスポンスは模擬データを返します。")

# レッスンコンテンツの読み込み
def load_lesson_content():
    try:
        with open(LESSON_CONTENT_FILE, 'r', encoding='utf-8') as f:
            lesson_data = json.load(f)
        print(f"レッスンコンテンツを {LESSON_CONTENT_FILE} から読み込みました")
        return lesson_data
    except FileNotFoundError:
        print(f"エラー: レッスンコンテンツファイルが見つかりません: {LESSON_CONTENT_FILE}")
        return None
    except json.JSONDecodeError:
        print(f"エラー: JSONデコードに失敗しました: {LESSON_CONTENT_FILE}")
        return None

# レッスンデータの初期化
lesson_data = load_lesson_content()
if lesson_data:
    print(f"レッスン数: {len(lesson_data.get('lessons', []))}")
else:
    print("警告: レッスンデータの読み込みに失敗しました。")

# AIレッスンクラス
class AILesson:
    def __init__(self, lesson_id, lesson_content=None):
        self.lesson_id = lesson_id
        self.lesson_content = lesson_content
        self.current_step = 0
        self.responses = []
    
    def start(self):
        # レッスンの初期化
        self.current_step = 0
        self.responses = []
        
        # 最初のプロンプトを取得
        return self.get_current_prompt()
    
    def get_current_prompt(self):
        if not self.lesson_content:
            return "レッスンコンテンツが読み込めませんでした。"
        
        # レッスンの終了確認
        if self.current_step >= len(self.lesson_content.get("steps", [])):
            return None
        
        # 現在のステップを取得
        step = self.lesson_content.get("steps", [])[self.current_step]
        return step.get("prompt", "プロンプトがありません。")
    
    def proceed(self, user_response):
        # ユーザーの回答を保存
        self.responses.append(user_response)
        
        # 次のステップへ移動
        self.current_step += 1
        
        # このステップに対するAIの応答を生成
        ai_response = self.generate_ai_response(user_response)
        
        # 次のプロンプトを取得
        next_prompt = self.get_current_prompt()
        
        return {
            "ai_response": ai_response,
            "next_prompt": next_prompt,
            "is_complete": next_prompt is None
        }
    
    def generate_ai_response(self, user_response):
        # 現在のレッスンステップを取得
        if self.current_step <= 0 or self.current_step > len(self.lesson_content.get("steps", [])):
            return "ステップが無効です。"
        
        current_step = self.lesson_content.get("steps", [])[self.current_step - 1]
        
        # AIの役割と指示を取得
        ai_role = current_step.get("ai_role", "教師")
        instructions = current_step.get("ai_instructions", "")
        
        # OpenAI APIが利用可能な場合、APIを使用
        if openai_client:
            try:
                # 会話用のメッセージを構築
                messages = [
                    {"role": "system", "content": f"あなたは英語学習アシスタントの{ai_role}です。{instructions}"},
                    {"role": "user", "content": user_response}
                ]
                
                # 前のステップの情報を追加
                if self.current_step > 1 and len(self.responses) > 0:
                    prev_step = self.lesson_content.get("steps", [])[self.current_step - 2]
                    messages.insert(1, {"role": "assistant", "content": prev_step.get("prompt", "")})
                    messages.insert(2, {"role": "user", "content": self.responses[-2]})
                
                print(f"OpenAI APIリクエスト: {messages}")
                
                # OpenAI APIを呼び出し
                response = openai_client.chat.completions.create(
                    model="gpt-4o",
                    messages=messages
                )
                return response.choices[0].message.content.strip()
            
            except Exception as e:
                print(f"AIレスポンス生成中にエラーが発生しました: {e}")
                return f"AIレスポンス生成エラーが発生しました: {str(e)}"
        
        # OpenAI APIが利用できない場合、モックレスポンスを生成
        return self._generate_mock_response(ai_role, instructions, user_response)
    
    def _generate_mock_response(self, role, instructions, user_response):
        """APIキーが設定されていない場合のモックレスポンスを生成"""
        print(f"モックレスポンスを生成: ロール={role}, ユーザー入力={user_response}")
        
        # ユーザー入力に基づいた簡単な応答を返す
        if "1" in user_response or "スタッフ" in user_response:
            return "スタッフ役を選択しました。では、お客様の発言に応答してみましょう。"
        
        if "2" in user_response or "客" in user_response or "お客" in user_response:
            return "お客様役を選択しました。では、スタッフの発言に応答してみましょう。"
        
        if "treatment" in user_response.lower() or "2" == user_response:
            return "正解です！「treatment」が「トリートメント」の英語表現です。"
        
        if "damage" in user_response.lower() or "3" == user_response:
            return "正解です！「damage」が「ダメージ」の英語表現です。"
        
        if "パーマ" in user_response or "3" == user_response:
            return "正解です！「perm」の日本語は「パーマ」です。"
        
        if "if you feel" in user_response.lower():
            return "良い文章です！「If you feel like...」の表現を上手に使えています。"
        
        # デフォルトの応答
        if self.current_step == 0:
            return "次のステップに進みましょう！"
        elif self.current_step == 1:
            return "役割を選んでいただきありがとうございます。"
        elif self.current_step == 2:
            return "英語での応答、よく頑張りました！次に進みましょう。"
        else:
            return "ご回答ありがとうございます。次に進みましょう。"

# ルート
@app.route('/')
def index():
    # セッションのクリア
    session.clear()
    
    # 利用可能なレッスンを取得
    available_lessons = []
    if lesson_data and lesson_data.get("lessons"):
        available_lessons = [{
            "id": lesson.get("lesson_id"),
            "title": lesson.get("title", f"Lesson {lesson.get('lesson_id')}")
        } for lesson in lesson_data.get("lessons")]
    
    return render_template('index.html', lessons=available_lessons)

@app.route('/api/lesson/start', methods=['POST'])
def start_lesson():
    # レッスンIDを取得
    lesson_id = request.json.get('lesson_id')
    if not lesson_id:
        return jsonify({"error": "レッスンIDが指定されていません"}), 400
    
    print(f"レッスン開始リクエスト: lesson_id={lesson_id}")
    
    # レッスンコンテンツを取得
    lesson_content = None
    if lesson_data and lesson_data.get("lessons"):
        for lesson in lesson_data.get("lessons"):
            if lesson.get("lesson_id") == lesson_id:
                lesson_content = lesson
                break
    
    if not lesson_content:
        print(f"エラー: レッスンID {lesson_id} が見つかりません")
        return jsonify({"error": f"レッスンID {lesson_id} が見つかりません"}), 404
    
    # セッションIDを作成
    session_id = str(uuid.uuid4())
    
    # レッスンを初期化
    ai_lesson = AILesson(lesson_id, lesson_content)
    
    # セッションデータを保存
    session['session_id'] = session_id
    session['lesson_id'] = lesson_id
    session['current_step'] = 0
    session['responses'] = []
    
    # レッスンを開始
    prompt = ai_lesson.start()
    
    print(f"レッスン開始完了: session_id={session_id}, 初期プロンプト={prompt[:50]}...")
    
    return jsonify({
        "session_id": session_id,
        "lesson_id": lesson_id,
        "prompt": prompt,
        "is_complete": prompt is None
    })

@app.route('/api/lesson/next', methods=['POST'])
def next_step():
    # セッションIDとユーザーの回答を取得
    session_id = session.get('session_id')
    if not session_id:
        return jsonify({"error": "アクティブなセッションがありません"}), 400
    
    user_response = request.json.get('response')
    if user_response is None:
        return jsonify({"error": "回答が提供されていません"}), 400
    
    print(f"次のステップリクエスト: session_id={session_id}, ユーザー応答={user_response}")
    
    # セッションからレッスンデータを取得
    lesson_id = session.get('lesson_id')
    current_step = session.get('current_step', 0)
    responses = session.get('responses', [])
    
    # レッスンコンテンツを取得
    lesson_content = None
    if lesson_data and lesson_data.get("lessons"):
        for lesson in lesson_data.get("lessons"):
            if lesson.get("lesson_id") == lesson_id:
                lesson_content = lesson
                break
    
    if not lesson_content:
        print(f"エラー: レッスンID {lesson_id} が見つかりません")
        return jsonify({"error": f"レッスンID {lesson_id} が見つかりません"}), 404
    
    # レッスンを初期化
    ai_lesson = AILesson(lesson_id, lesson_content)
    ai_lesson.current_step = current_step
    ai_lesson.responses = responses
    
    # ユーザーの回答を処理
    result = ai_lesson.proceed(user_response)
    
    # セッションデータを更新
    session['current_step'] = ai_lesson.current_step
    session['responses'] = ai_lesson.responses
    
    print(f"次のステップ完了: current_step={ai_lesson.current_step}, AIレスポンス={result.get('ai_response', '')[:50]}...")
    
    return jsonify({
        "ai_response": result.get("ai_response"),
        "next_prompt": result.get("next_prompt"),
        "is_complete": result.get("is_complete", False)
    })

@app.route('/api/status', methods=['GET'])
def api_status():
    """APIの状態をチェックするエンドポイント"""
    status = {
        "openai_api": openai_client is not None,
        "lessons_loaded": lesson_data is not None,
        "lesson_count": len(lesson_data.get("lessons", [])) if lesson_data else 0,
        "env_vars": {
            "OPENAI_API_KEY": bool(openai_api_key)
        }
    }
    return jsonify(status)

if __name__ == "__main__":
    print(f"Flaskアプリケーションを起動します...")
    print(f"OS/環境: {sys.platform}, Python {sys.version}")
    
    if not openai_api_key or openai_api_key == "your_openai_key_here":
        print("\n" + "="*80)
        print("警告: 有効なOpenAI APIキーが設定されていません")
        print("以下のいずれかの方法でAPIキーを設定してください:")
        print("1. `.env`ファイルに`OPENAI_API_KEY=あなたのAPIキー`を記述")
        print("2. 環境変数を直接設定: export OPENAI_API_KEY=あなたのAPIキー")
        print("APIキーはhttps://platform.openai.com/account/api-keysで取得できます")
        print("="*80 + "\n")
        print("APIキーなしでモックモードで実行します（応答は実際のAIではありません）")
    
    port = 8000
    print(f"\n{'-'*40}")
    print(f"アプリケーションが起動しました。以下のURLでアクセスできます:")
    print(f"ローカル: http://127.0.0.1:{port}")
    print(f"ネットワーク: http://[あなたのIPアドレス]:{port}")
    print(f"{'-'*40}\n")
    
    # すべてのネットワークインターフェースでリッスン
    app.run(debug=True, port=port, host='0.0.0.0') 
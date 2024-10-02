# saju_naming_web
구글 머신러닝 부트캠프 5기에서 진행한 Gemma 2 Sprint 프로젝트다.  
해당 프로젝트에서 사주를 이용하여 이름을 추천해주는 모델을 fine-tuning을 통해 구현하였다.  
자세한 내용은 [saju_naming](https://github.com/5KLetsGo/saju_naming)에서 확인할 수 있다.

## Model
- **fine-tuning model** : [5KLetsGo/saju-naming](https://huggingface.co/5KLetsGo/saju-naming)
  - Developed by: 유혁진, 강승곤, 이도건
- **base model** : [rtzr/ko-gemma-2-9b-it](https://huggingface.co/rtzr/ko-gemma-2-9b-it)

### 학습 방식
1. 8bit Quantization 사용하여 base model 불러오기
2. lora 방식으로 fine-tuning 준비
    - target modules : k_proj, o_proj, v_proj, q_proj, gate_proj, up_proj, down_proj
      - self-attention : k_proj, o_proj, v_proj, q_proj
      - gemma2 mlp : gate_proj, up_proj, down_proj
3. SFTTrainer를 사용하여 학습
4. base model과 lora model을 merge하여 fine-tuning model 구현

### 데이터

수집한 데이터
- 한국 남자 이름
- 한국 여자 이름
- 인명 한자
- 음양력 날짜

학습시킨 (질문, 답변) 형식의 prompt
- 자원 오행 별 인명 한자 prompt
- 자원 오행 해석 prompt
- 한국 남자 이름 prompt
- 한국 여자 이름 prompt
- 자원 오행을 활용한 작명 prompt
- 이름 의미 prompt

### Gemma 2 모델 구조
```
Gemma2ForCausalLM(
  (model): Gemma2Model(
    (embed_tokens): Embedding(256000, 4608, padding_idx=0)
    (layers): ModuleList(
      (0-45): 46 x Gemma2DecoderLayer(
        (self_attn): Gemma2SdpaAttention(
          (q_proj): Linear(in_features=4608, out_features=4096, bias=False)
          (k_proj): Linear(in_features=4608, out_features=2048, bias=False)
          (v_proj): Linear(in_features=4608, out_features=2048, bias=False)
          (o_proj): Linear(in_features=4096, out_features=4608, bias=False)
          (rotary_emb): Gemma2RotaryEmbedding()
        )
        (mlp): Gemma2MLP(
          (gate_proj): Linear(in_features=4608, out_features=36864, bias=False)
          (up_proj): Linear(in_features=4608, out_features=36864, bias=False)
          (down_proj): Linear(in_features=36864, out_features=4608, bias=False)
          (act_fn): PytorchGELUTanh()
        )
        (input_layernorm): Gemma2RMSNorm()
        (post_attention_layernorm): Gemma2RMSNorm()
        (pre_feedforward_layernorm): Gemma2RMSNorm()
        (post_feedforward_layernorm): Gemma2RMSNorm()
      )
    )
    (norm): Gemma2RMSNorm()
  )
  (lm_head): Linear(in_features=4608, out_features=256000, bias=False)
)
```

## Front-End
flutter를 이용해 web으로 Front-End를 구현하였다.  
Developed by: 유혁진  
[웹페이지 GitHub](https://github.com/5KLetsGo/saju_naming_web)  
[웹페이지](https://5kletsgo.github.io/saju_naming_web/)  


### github에 올리는 법
1. flutter로 application을 구현한다.
2. 'flutter build web' 으로 web을 빌드한다.
3. 이후, ./build/web/index.html 에서 \<base href="/"\>을 \<base href="/saju_naming_web/"\> 으로 변경  
('flutter build web --base-href "/saju_naming_web/"'로 build 옵션을 변경 가능하다)
4. cd ./build/web 으로 이동 후 다음 명령어로 git에 업로드한다.  
```
git init
git remote add origin '본인 git 주소'
git add .
git commit -m "web deploy"
git push -f origin main // "-f" 강제로 push 하기
```
5. Git 저장소의 Settings -> Pages -> Branch 설정 후 저장하기

## Back-End
Google Colab과 Flask, ngrok를 이용하여 Back-End를 구현하였다.  
[saju_naming_server.ipynb](https://github.com/5KLetsGo/saju_naming/blob/main/saju_naming_server.ipynb)를 참고할 수 있다.  
Developed by: 유혁진, 강승곤  

### Flask
Flask란 python 기반으로 작성된 Micro Web Framework 중 하나다.  
간단한 웹 사이트, 혹은 간단한 API 서버를 만드는 데에 특화 되어있는 Python Web Framework이다.

### ngrok
[ngrok](https://ngrok.com/) 란 외부 인터넷 망에서 로컬 PC로 접속하는 방법을 제공하는 툴이다.


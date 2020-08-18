# :articulated_lorry: CARAVAN_Insurance_subscription_prediction :articulated_lorry: <br>

<br>

### 2020.06 데이터마이닝 수업 프로젝트
&nbsp;&nbsp; 데이터마이닝 수업의 일환으로 수업시간에 배운 내용을 바탕으로 실제 데이터를 분석하는 프로젝트입니다. 이동식 주택 보험 가입 여부를 예측하고 그에 관련된 인싸이트를 찾는 것이 목표입니다. <br>

<br>

## :bulb: 전체적인 분석목표
 - **Logistic Regression**
    + 많은 머신러닝, 딥러닝 기법들이 존재하나 여전히 준수한 예측력을 보이며 특히 **해석가능한 모형**이라는 장점을 가진 로지스틱회귀분석을 활용하여 보험가입 여부 예측에서 더 나아가 어떤 요인이 보험가입 여부에 영향을 미치는지 파악하고자 합니다.<br>
 - 캠핑족이 상당히 많은 네덜란드의 특성상 이동식 주택 보험 시장이 매우 크며 이에 대한 예측과 보험에 가입하는 사람들의 특징을 알아내는 것은 매우 중요한 분석이 될 수 있습니다.
 
<br>

## :file_folder: 파일 구조
```
├──  CARAVAN_Insurance_subscription_prediction_Project/
   ├── Preprocessing.R
   └── Modeling.R 
```
 - `Preprocessing.R` 데이터를 불러오기, 파생변수 생성, 이상치 처리등의 전처리 내용이 담겨있는 파일입니다.
 - `Modeling.R` 최종 데이터를 활용하여 PCA 및 Logistic Regression 모델을 학습시키는 파일입니다.   
 
  <br>
 
 <img src="https://user-images.githubusercontent.com/61648914/90542598-520fed00-e1bf-11ea-9bda-b4a81cc940c8.png" width="50%" height="30%" title="px(픽셀) 크기 설정"><img src="https://user-images.githubusercontent.com/61648914/90542647-6653ea00-e1bf-11ea-9dab-5ef1798debbc.png" width="50%" height="30%" title="px(픽셀) 크기 설정">
 
  ## :disappointed: 아쉬운점
  - DNN, Stcking 등을 활용한다면 더 좋은 예측력을 보이는 모형을 구축할 수 있을 것입니다. <br>
  - 워낙 오래전 데이터라 추가적인 데이터를 구하기 힘들고 변수가 각 개인의 값이 아닌 지역의 정보로 되어있어 정확도가 떨어집니다. <br>
  - 보험회사의 입장에서 보험홍보에 들어가는 비용과 실제 가입한 사람을 맞추는 비율을 통해 총 비용을 계산하여 더 최적의 Threshold를 찾을 수 있을 것입니다. <br>

- [�����:ray&tagging](#�����raytagging)
  - [Ray](#ray)
    - [Ray cluster �](#ray-cluster-�)
      - [header �ڵ�](#header-�ڵ�)
      - [worker�ڵ�](#worker�ڵ�)
  - [tagging](#tagging)
    - [tagging������������װ](#tagging������������װ)



# �����:ray&tagging

## Ray

+ ǰ�᣺������а�װ�� python �� pip

+ ��װ ray ���·��а棺

  ```shell
  sudo apt-get update
  sudo pip3 install -U ray
  sudo pip3 install 'ray[default]' #����cli����
  ```

  ע�����ܻ��������±���

  > The directory 'xxx' or its patent directory is not owned by the current...

  ��� warning �����ݴ���ǣ���ǰ�û���ӵ��Ŀ¼���丸Ŀ¼�����һ����ѱ����á����Ժ������ warning�������Ҫ���������޸�Ϊ�������

  ```shell
  sudo -H pip3 install ...
  ```

  ��װ������£�

  <img src="image\image-20220408161425411.png" alt="image-20220408161425411" style="zoom:80%;" />

+ ���⣬�ҵ� python �汾�� 3.6.9��֮����ܻ���Ҫͳһ�ֲ�ʽ��Ⱥ�� python �汾

### Ray cluster �

ǰ��Ҫ�󣺸�̨��������**ͬһ��������**�У���װ��**��ͬ�汾��python��ray**��

#### header �ڵ�

```shell
ray start --head --port=6379
```

<img src="image\image-20220408162006133.png" alt="image-20220408162006133" style="zoom:67%;" />

#### worker�ڵ�

```shell
ray start --address='192.168.10.132:6379' --redis-password='5241590000000000' #��ʵ������޸�address
```

Ԥ�ڿ������½���

<img src="image\image-20220408162751753.png" alt="image-20220408162751753" style="zoom:80%;" />

���Ҫ�˳���Ⱥ��ֻ��

```shell
ray stop
```

## tagging

### tagging������������װ

Ĭ������Ϊ�廪Դ

```shell
pip install pdfplumber
pip install sphinx
pip install ffmpeg	#��һ���������,���� warning ����Ӧ���޸�Ϊ��sudo apt install ffmpeg

pip install SpeechRecognition
pip install tinytag
pip install pydub
pip install nltk
pip install spacy
python -m nltk.downloader stopwords
python -m nltk.downloader universal_tagset
python3 -m spacy download en
pip install git+https://github.com/boudinfl/pke.git
```



���ܳ��ֵ������Լ����������

1. ���ܻ�������� warning��

   ![image-20220408165842811](image\image-20220408165842811.png)

   ������������ᵽ��·����ӵ���������

   ```shell
   vim ~/.bashrc
   export PATH=/home/xxx/.local/bin/:$PATH #��һ�з��� .bashrc �ļ������xxx �滻Ϊ����û���
   source ~/.bashrc
   ```

2. ֻ�� python3 ��װ������ python ��װ

   ���������Ϊ /usr/bin ����ֻ�� python3 ���û�� python ��������������һ�������ӣ�

   `sudo ln -s /usr/bin/python3 /usr/bin/python`

3. pip3 ��װ����

   ʹ�� pip ��װ

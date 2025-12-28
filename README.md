# ComfyUI をコンテナに閉じ込めるやつ

## 前提

依存関係をアレするために CUDA 12.8 で止めようとしている

- NVIDIA が刺さった適当なディストリ（WSL2 環境を想定）
- Docker が入っている
- [NVIDIA Container Toolkit 12.8](https://developer.nvidia.com/cuda-12-8-1-download-archive) が設定済みである
  - 以下も実行済みである:
    ```shell
    sudo nvidia-ctk runtime configure --runtime=docker
    sudo systemctl restart docker
    ```

## 設定

### `.env` の設定

1. プロジェクトルートの `.env_example` を `.env` としてコピー
2. ファイル内の各項目を自分の環境に合わせて変更（デフォルトはプロジェクト内の各ディレクトリを参照する）

以下は各項目のざっくりした説明

| 項目 | 説明 |
| --- | --- |
| MODELS | ComfyUI の `models` ディレクトリにマウントされる。 <br/> `checkpoint` を入れたければ `checkpoint` を、 `loras` を入れたければ `loras` ディレクトリを切る必要がある。 |
| INPUT | ComfyUI の `input` ディレクトリにマウントされる。 |
| OUTPUT | ComfyUI の `output` ディレクトリにマウントされる。 <br/> 生成された画像はこのディレクトリに吐き出されるということ。 |
| DATA | ComfyUI の `user` ディレクトリにマウントされる。 <br/> ブラウザでの設定やワークフローテンプレート、ログなどを永続化するのが目的。 |
| CUSTOM_WILDCARDS | ComfyUI Impact Pack の Impact Wildcard を想定したもの。 <br/> `custom_nodes/comfyui-impact-pack/custom_wildcards` にマウントされ、ワイルドカードファイルを配置できる。 |
| TORCH_CUDA_ARCH_LIST |  `SageAttention` のビルドに使う環境変数。 <br/> Blackwell なら `9`, RTX 4000 シリーズなら `8.9`,  RTX 3000 シリーズなら `8.6`, RTX 2000 シリーズなら `7.5` といった具合に設定。 |

## 実行

1. このリポジトリを clone し、ディレクトリに入る
2. `docker compose build` でイメージをビルド
3. `docker compose up -d` で起動

Custom Nodes とその依存関係を永続化したいという思いから `custom_nodes` ディレクトリや `pip` の依存関係は Volume に永続化される。邪魔になったら必要に応じて消し飛ばすなどする。
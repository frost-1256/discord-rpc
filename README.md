# discord-rpc

[Discord-RPC-Extension](https://github.com/lolamtisch/Discord-RPC-Extension) のサーバーを Nix/NixOS で簡単に実行・管理するための flake です。

サーバーバイナリは GitHub Releases から自動でダウンロードします(リポジトリには含めていません)。

## 直接実行

```console
$ nix run github:frost-1256/discord-rpc
```

## NixOS への組み込み方

flake の `nixosModules.default` を import し、`services.rpc-server.enable` を有効にするだけです。

```nix
# flake.nix
{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    rpc-server.url = "github:frost-1256/discord-rpc";
    rpc-server.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = { nixpkgs, rpc-server, ... }: {
    nixosConfigurations.myhost = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      modules = [
        rpc-server.nixosModules.default
        {
          services.rpc-server.enable = true;
        }
      ];
    };
  };
}
```

## オプション

| オプション | 型 | 説明 |
| --- | --- | --- |
| `services.rpc-server.enable` | bool | rpc-server の systemd user サービスを有効にする |
| `services.rpc-server.package` | package | 使用するパッケージ(デフォルトは本 flake のパッケージ) |

## systemd user サービスについて

有効にすると、GUI セッション開始時に自動で起動する user サービス `rpc-server.service` が生成されます。

- `After=`/`PartOf=` `graphical-session.target` — セッション終了時に一緒に停止
- `Restart=on-failure` — クラッシュ時に自動再起動

```console
$ systemctl --user status rpc-server
$ systemctl --user restart rpc-server
$ journalctl --user -u rpc-server -f
```

## 開発

```console
$ nix flake check   # flake とモジュールの検証
$ nix run .         # サーバーを直接起動
```

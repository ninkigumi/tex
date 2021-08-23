FROM ubuntu:21.04

LABEL maintainer="koba1014@gmail.com"

ENV TL_VERSION      2021
ENV TL_PATH         /usr/local/texlive
ENV PATH            ${TL_PATH}/bin/x86_64-linux:${TL_PATH}/bin/aarch64-linux:/bin:${PATH}

WORKDIR /tmp

# Install required packages
RUN apt update && \
    apt upgrade -y && \
    apt install -y \
    # Basic tools
    wget unzip ghostscript \
    # for tlmgr
    perl-modules-5.32 \
    # for XeTeX
    fontconfig && \
    # Clean caches
    apt autoremove -y && \
    apt clean && \
    rm -rf /var/cache/apt/archives/* /var/lib/apt/lists/*

# Install TeX Live
RUN mkdir install-tl-unx && \
    wget -qO- http://mirror.ctan.org/systems/texlive/tlnet/install-tl-unx.tar.gz | \
      tar -xz -C ./install-tl-unx --strip-components=1 && \
    printf "%s\n" \
      "TEXDIR ${TL_PATH}" \
      "selected_scheme scheme-full" \
      "option_doc 0" \
      "option_src 0" \
      > ./install-tl-unx/texlive.profile && \
    ./install-tl-unx/install-tl \
      -profile ./install-tl-unx/texlive.profile \
      -repository https://ctan.math.washington.edu/tex-archive/systems/texlive/tlnet/ && \
    rm -rf *

# Set up Japanese fonts
RUN tlmgr repository add http://contrib.texlive.info/current tlcontrib && \
    tlmgr pinning add tlcontrib '*' && \
    tlmgr install \
      collection-latexextra \
      collection-fontsrecommended \
      collection-langjapanese \
      japanese-otf-nonfree \
      japanese-otf-uptex-nonfree \
      ptex-fontmaps-macos \
      cjk-gs-integrate-macos && \
    kanji-config-updmap-sys --force --jis2004 hiragino-highsierra-pron && \
    cjk-gs-integrate --link-texmf --force \
      --fontdef-add=$(kpsewhich -var-value=TEXMFDIST)/fonts/misc/cjk-gs-integrate-macos/cjkgs-macos-highsierra.dat && \
    # Set up hiragino and the other Japanese fonts link.
    ln -s /usr/share/fonts/SystemLibraryFonts/"ヒラギノ明朝 ProN.ttc" /usr/local/texlive/texmf-local/fonts/opentype/cjk-gs-integrate/HiraginoSerif.ttc && \
    ln -s /usr/share/fonts/SystemLibraryFonts/"ヒラギノ丸ゴ ProN W4.ttc" /usr/local/texlive/texmf-local/fonts/opentype/cjk-gs-integrate/HiraginoSansR-W4.ttc && \
    ln -s /usr/share/fonts/SystemLibraryFonts/"ヒラギノ角ゴシック W0.ttc" /usr/local/texlive/texmf-local/fonts/opentype/cjk-gs-integrate/HiraginoSans-W0.ttc && \
    ln -s /usr/share/fonts/SystemLibraryFonts/"ヒラギノ角ゴシック W1.ttc" /usr/local/texlive/texmf-local/fonts/opentype/cjk-gs-integrate/HiraginoSans-W1.ttc && \
    ln -s /usr/share/fonts/SystemLibraryFonts/"ヒラギノ角ゴシック W2.ttc" /usr/local/texlive/texmf-local/fonts/opentype/cjk-gs-integrate/HiraginoSans-W2.ttc && \
    ln -s /usr/share/fonts/SystemLibraryFonts/"ヒラギノ角ゴシック W3.ttc" /usr/local/texlive/texmf-local/fonts/opentype/cjk-gs-integrate/HiraginoSans-W3.ttc && \
    ln -s /usr/share/fonts/SystemLibraryFonts/"ヒラギノ角ゴシック W4.ttc" /usr/local/texlive/texmf-local/fonts/opentype/cjk-gs-integrate/HiraginoSans-W4.ttc && \
    ln -s /usr/share/fonts/SystemLibraryFonts/"ヒラギノ角ゴシック W5.ttc" /usr/local/texlive/texmf-local/fonts/opentype/cjk-gs-integrate/HiraginoSans-W5.ttc && \
    ln -s /usr/share/fonts/SystemLibraryFonts/"ヒラギノ角ゴシック W6.ttc" /usr/local/texlive/texmf-local/fonts/opentype/cjk-gs-integrate/HiraginoSans-W6.ttc && \
    ln -s /usr/share/fonts/SystemLibraryFonts/"ヒラギノ角ゴシック W7.ttc" /usr/local/texlive/texmf-local/fonts/opentype/cjk-gs-integrate/HiraginoSans-W7.ttc && \
    ln -s /usr/share/fonts/SystemLibraryFonts/"ヒラギノ角ゴシック W8.ttc" /usr/local/texlive/texmf-local/fonts/opentype/cjk-gs-integrate/HiraginoSans-W8.ttc && \
    ln -s /usr/share/fonts/SystemLibraryFonts/"ヒラギノ角ゴシック W9.ttc" /usr/local/texlive/texmf-local/fonts/opentype/cjk-gs-integrate/HiraginoSans-W9.ttc && \
    ln -s /usr/share/fonts/SystemLibraryAssetsV2/com_apple_MobileAsset_Font6/47405a357e3ac82b7afbf33f535962172e3e3d10.asset/AssetData/Osaka.ttf /usr/local/texlive/texmf-local/fonts/opentype/cjk-gs-integrate/Osaka.ttf && \
    ln -s /usr/share/fonts/SystemLibraryAssetsV2/com_apple_MobileAsset_Font6/eca12ba29af8fda43b3ebe09ae1c0606adc65a27.asset/AssetData/OsakaMono.ttf /usr/local/texlive/texmf-local/fonts/opentype/cjk-gs-integrate/OsakaMono.ttf && \
    ln -s /usr/share/fonts/SystemLibraryAssetsV2/com_apple_MobileAsset_Font6/a5578564cd8cb162d7ba1544317ef3ae407bf939.asset/AssetData/Klee.ttc /usr/local/texlive/texmf-local/fonts/opentype/cjk-gs-integrate/Klee.ttc && \
    ln -s /usr/share/fonts/SystemLibraryAssetsV2/com_apple_MobileAsset_Font6/8def8795a8bc5906be76cb45d9ca92ff305adb0f.asset/AssetData/TsukushiAMaruGothic.ttc /usr/local/texlive/texmf-local/fonts/opentype/cjk-gs-integrate/TsukushiAMaruGothic.ttc && \
    ln -s /usr/share/fonts/SystemLibraryAssetsV2/com_apple_MobileAsset_Font6/6ec5cb139687d842d0186f98215ef1c477df6cc0.asset/AssetData/TsukushiBMaruGothic.ttc /usr/local/texlive/texmf-local/fonts/opentype/cjk-gs-integrate/TsukushiBMaruGothic.ttc && \
    ln -s /usr/share/fonts/SystemLibraryAssetsV2/com_apple_MobileAsset_Font6/5ef536f846908ec81f4b37caef397b3cb050b64e.asset/AssetData/ToppanBunkyuGothicPr6N.ttc /usr/local/texlive/texmf-local/fonts/opentype/cjk-gs-integrate/ToppanBunkyuGothicPr6N.ttc && \
    ln -s /usr/share/fonts/SystemLibraryAssetsV2/com_apple_MobileAsset_Font6/d37ed4f492e87221b72d5c3aa5d4ff76e6d37c87.asset/AssetData/ToppanBunkyuMinchoPr6N-Regular.otf /usr/local/texlive/texmf-local/fonts/opentype/cjk-gs-integrate/ToppanBunkyuMinchoPr6N-Regular.otf && \
    ln -s /usr/share/fonts/SystemLibraryAssetsV2/com_apple_MobileAsset_Font6/c7c8e5cb889b80fff0175bf138a7b66c6f027f21.asset/AssetData/ToppanBunkyuMidashiGothicStdN-ExtraBold.otf /usr/local/texlive/texmf-local/fonts/opentype/cjk-gs-integrate/ToppanBunkyuMidashiGothicStdN-ExtraBold.otf && \
    ln -s /usr/share/fonts/SystemLibraryAssetsV2/com_apple_MobileAsset_Font6/14a24f75750dfdd5cb190b7d808e8d4731888704.asset/AssetData/ToppanBunkyuMidashiMinchoStdN-ExtraBold.otf /usr/local/texlive/texmf-local/fonts/opentype/cjk-gs-integrate/ToppanBunkyuMidashiMinchoStdN-ExtraBold.otf && \
    ln -s /usr/share/fonts/SystemLibraryAssetsV2/com_apple_MobileAsset_Font6/bf3dc4579b9aab95801aaba773fc9bb83893b991.asset/AssetData/Kyokasho.ttc /usr/local/texlive/texmf-local/fonts/opentype/cjk-gs-integrate/Kyokasho.ttc && \
    ln -s /usr/share/fonts/SystemLibraryAssetsV2/com_apple_MobileAsset_Font6/00a83746b65bd0a829eba9a553e88c60b18f89d7.asset/AssetData/YuGothic-Medium.otf /usr/local/texlive/texmf-local/fonts/opentype/cjk-gs-integrate/YuGothic-Medium.otf && \
    ln -s /usr/share/fonts/SystemLibraryAssetsV2/com_apple_MobileAsset_Font6/16410f7b0c96b4bb08d952fa04d67cd65a42f1b7.asset/AssetData/YuGothic-Bold.otf /usr/local/texlive/texmf-local/fonts/opentype/cjk-gs-integrate/YuGothic-Bold.otf && \
    ln -s /usr/share/fonts/SystemLibraryAssetsV2/com_apple_MobileAsset_Font6/bdee83ea598d4a36c665b2095e0f39376e9c182b.asset/AssetData/YuMincho.ttc /usr/local/texlive/texmf-local/fonts/opentype/cjk-gs-integrate/YuMincho.ttc && \    
    mktexlsr && \
    luaotfload-tool --update --force && \
    fc-cache -r && \
    kanji-config-updmap-sys status && \
    # Set up latexmk and llmk
    tlmgr install \
      latexmk && \
    wget -q -O /usr/local/bin/llmk https://raw.githubusercontent.com/wtsnjp/llmk/master/llmk.lua && \
    chmod +x /usr/local/bin/llmk


VOLUME ["/usr/local/texlive/${TL_VERSION}/texmf-var/luatex-cache"]

WORKDIR /workdir

CMD ["bash"]

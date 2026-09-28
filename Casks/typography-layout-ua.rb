cask "typography-layout-ua" do
  version "1.0.0"
  sha256 "7ba4a70f8cd8ce7ab1114b412eb9c58cbc3272f08108ec82227f665d8925436c"

  url "https://github.com/nik-holo/typography-layout-ua/releases/download/v#{version}/typography-layout-ua-#{version}.zip"
  name "Typography Layout UA"
  desc "Ilya Birman typography keyboard layout adapted for Ukrainian"
  homepage "https://github.com/nik-holo/typography-layout-ua"

  livecheck do
    url :url
    strategy :github_latest
  end

  depends_on :macos

  keyboard_layout "Typography Layout UA.bundle"

  caveats do
    reboot
  end
end

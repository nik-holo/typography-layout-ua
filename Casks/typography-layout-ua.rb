cask "typography-layout-ua" do
  version "1.0.0"
  sha256 "cff2b57d9e2d41688ff6b112a822bc97ff26c3d311c19a0b9017b1982069d188"

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

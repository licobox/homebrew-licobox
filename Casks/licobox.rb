cask "licobox" do
  name "Licobox"
  desc "Licobox, docker engine runtime on macos"
  homepage "https://licobox.dev"

  arch arm: "arm64"
  os macos: "darwin"
  depends_on macos: ">= :sequoia"

  version "v1.0.0-alpha29"
  sha256 "8b7987771805f9c893b9710503161c8f4564ef8d6895fe1255c02ffa3a67394a"

  livecheck do
    url "https://app.licobox.dev/artifacts/download?check_for_update=1&version=latest"
    strategy :json do |json, regex|
      json["version"]
    end
  end

  auto_updates true

  url "https://app.licobox.dev/artifacts/download?version=#{version}"

  app "Licobox.app"
  binary "#{appdir}/Licobox.app/Contents/Resources/binaries/licobox/bin/licobox"

  binaries_path = "#{staged_path}/Licobox.app/Contents/Resources/binaries/licobox"

  fish_completion_path = "#{staged_path}/completions/fish/licobox.fish"
  FileUtils.mkdir_p File.dirname(fish_completion_path)
  File.write(fish_completion_path, "")
  fish_completion "#{fish_completion_path}"

  preflight do
    system "/usr/bin/xattr", "-cr", "#{staged_path}/Licobox.app" if OS.send(:mac?) && Hardware::CPU.send(:arm?)
  end
  
  postflight do
    fish_completion_output = `"#{binaries_path}/bin/licobox" completion fish`
    File.write(fish_completion_path, fish_completion_output)
  end

  uninstall quit: "dev.licobox.licobox-app"

  # zap trash: "~/.licobox"

  def caveats
    <<~EOS
    Docker client is required to interact with Licobox docker engine.
    You can install Docker CLI using brew `brew install docker`.
    Skip this step if you already have or installed one.
    EOS
  end
end

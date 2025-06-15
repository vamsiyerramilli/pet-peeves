require 'xcodeproj'

post_install do |installer|
  ## ------------------------------------------------------------------
  ## 1. Patch Pods-Runner-frameworks.sh to prevent "source: unbound".
  ## ------------------------------------------------------------------
  fwk_script = File.join(__dir__, 'Pods/Target Support Files/Pods-Runner/Pods-Runner-frameworks.sh')
  if File.exist?(fwk_script)
    text = File.read(fwk_script)
    unless text.include?('local source=""')
      puts '🔧  Injecting local source="" into Pods-Runner-frameworks.sh'
      # insert after first line of install_framework() function
      text.sub!(/install_framework\(\)\s*\{/, "install_framework() {\n  local source=\"\"\n")
      File.write(fwk_script, text)
    end
  end

  ## ------------------------------------------------------------------
  ## 2. Add build-phase that deletes .symlinks from final bundle.
  ## ------------------------------------------------------------------
  # Open Runner project
  proj_path = File.join(__dir__, 'Runner.xcodeproj')
  if File.exist?(proj_path)
    project = Xcodeproj::Project.open(proj_path)
    runner_target = project.targets.find { |t| t.name == 'Runner' }
    if runner_target
      phase_name = 'Remove .symlinks from bundle'
      unless runner_target.shell_script_build_phases.any? { |p| p.name == phase_name }
        puts '🔧  Adding "Remove .symlinks from bundle" build phase to Runner target'
        phase = runner_target.new_shell_script_build_phase(phase_name)
        phase.shell_script = <<~EOS
          SYM_PATH="${TARGET_BUILD_DIR}/${WRAPPER_NAME}/Frameworks/.symlinks"
          if [ -d "$SYM_PATH" ]; then
            echo "Deleting $SYM_PATH"
            rm -rf "$SYM_PATH"
          fi
        EOS
        # ensure phase runs after Embed Frameworks
        runner_target.build_phases.move(phase, runner_target.build_phases.count - 1)
        project.save
      end
    end
  end

  ## ------------------------------------------------------------------
  ## 3. Remove any existing .symlinks dir from previous builds.
  ## ------------------------------------------------------------------
  app_symlink_path = File.join(__dir__, '../build/ios/iphonesimulator/Runner.app/Frameworks/.symlinks')
  if File.exist?(app_symlink_path)
    puts '🔧  Removing leftover .symlinks from previous build'
    FileUtils.rm_rf(app_symlink_path)
  end
end 
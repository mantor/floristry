desc "Build arch.png"
task :arch_png do
  sh "dot -Tpng arch.dot -o arch.png"
end

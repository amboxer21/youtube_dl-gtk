#!/usr/bin/ruby

require 'gtk2'
require 'fileutils'

# Envirenment variables
$baseDir  = ENV['HOME']
$musicDir = "#{$baseDir}/Music"

window = Gtk::Window.new
#window.set_default_size(200, 100)

window.signal_connect("destroy") {
       Gtk.main_quit
}

window.signal_connect("delete_event") {
       false
}

table = Gtk::Table.new(5,6,true)
window.add(table)

$entry = Gtk::Entry.new
table.attach($entry, 1,5,5,6)

labelURL = Gtk::Label.new
labelURL.set_markup("<b>U2B URL: </b>")
table.attach(labelURL,0,1,5,6)

$entryDir = Gtk::Entry.new
table.attach($entryDir, 1,5,4,5)

labelDir = Gtk::Label.new
labelDir.set_markup("<b>Save to: </b>")
table.attach(labelDir,0,1,4,5)

error = Gtk::Button.new("Error")

error.signal_connect("clicked") {
       on_error
}

tooltipURL = Gtk::Tooltips.new
tooltipURL.set_tip($entry, "Enter youtube URL or properly formatted playlist here.", nil)

tooltipDir = Gtk::Tooltips.new
tooltipDir.set_tip($entryDir, "Enter the directory you wish to save the song to. \nIf it doesnt exist, it will be created", nil)

buttonLogo = Gtk::Button.new
table.attach(buttonLogo,0,5,0,4)

buttonLogoImage = Gtk::Image.new("youtube-logo-transparent_solid.png")
buttonLogo.image = buttonLogoImage

def fileOperation(file,flag,string)
        if flag == "a"
               open(file,"a") do |line|
                     line.puts string
               end
        elsif flag == "r"
               open(file,"r").each_line do |line|
                     puts line
               end       
        end
end

def on_error
        md = Gtk::MessageDialog.new(nil, Gtk::Dialog::MODAL | 
             Gtk::Dialog::DESTROY_WITH_PARENT, Gtk::MessageDialog::ERROR, 
             Gtk::MessageDialog::BUTTONS_CLOSE, "No URL specified.")
        md.run
        md.destroy
end

def delete_text
       if !File.exists?("#{$baseDir}/.youtube_dl-gtk")
               Dir::mkdir "#{$baseDir}/.youtube_dl-gtk"
       end

       fileOperation("#{$baseDir}/.youtube_dl-gtk/history","a","#{$entry.text}") 
       $entry.delete_text(0,$entry.text.length)
end

def download(dir,entry,val)
       if val == 1
              `youtube-dl --prefer-avconv --extract-audio --audio-format mp3 -o "#{dir}/%(title)s.%(ext)s" "#{entry}/%(title)s.%(ext)s"`
       elsif val == 0
              `youtube-dl --prefer-avconv --extract-audio --audio-format mp3 -o "#{dir}/#{dir}/%(title)s.%(ext)s" "#{entry}"`
       end
end

button = Gtk::Button.new("Download")
table.attach(button,5,6,5,6)
button.signal_connect("clicked") do

       if File.exists?($musicDir) && $entryDir.text.empty? && !$entry.text.empty?
              #`youtube-dl --extract-audio --audio-format mp3 -o "#{$musicDir}/%(title)s.%(ext)s" "#{$entry.text}/%(title)s.%(ext)s"`
              download($musicDir,$entry.text,1)
              delete_text
       elsif !File.exists?($musicDir) && $entryDir.text.empty?
              Dir::mkdir "#{ENV['HOME']}/Music"
              #`youtube-dl --extract-audio --audio-format mp3 -o "#{$musicDir}/%(title)s.%(ext)s" "#{$entry.text}/%(title)s.%(ext)s"`
              download($musicDir,$entry.text,1)
              delete_text
       elsif !$entryDir.text.empty? && !$entry.text.empty?
              if File.exists?("#{$baseDir}/#{$entryDir.text}")
                     #`youtube-dl --extract-audio --audio-format mp3 -o "#{$baseDir}/#{$entryDir.text}/%(title)s.%(ext)s" "#{$entry.text}"`
                     download("#{$baseDir}/#{$entryDir}",$entry.text,0)
                     delete_text
              else
                     FileUtils::mkdir_p "#{$baseDir}/#{$entryDir.text}"
                     #`youtube-dl --extract-audio --audio-format mp3 -o "#{$baseDir}/#{$entryDir.text}/%(title)s.%(ext)s" "#{$entry.text}"`
                     download("#{$baseDir}/#{$entryDir}",$entry.text,0)
                     delete_text
              end
       elsif $entry.text.empty?
              puts "Entry is empty."
              on_error
       end
end

table.show
$entry.show
button.show
window.show
labelDir.show
labelURL.show
$entryDir.show
buttonLogo.show

Gtk.main

#!/usr/bin/ruby

require 'gtk2'
require 'fileutils'

window = Gtk::Window.new
#window.set_default_size(200, 100)

window.signal_connect("destroy") {
       Gtk.main_quit
}

window.signal_connect("delete_event") {
       false
}

table = Gtk::Table.new(5,5,true)
window.add(table)

entry = Gtk::Entry.new
table.attach(entry, 0,4,4,5)

entryDir = Gtk::Entry.new
table.attach(entryDir, 0,4,3,4)

error = Gtk::Button.new("Error")

error.signal_connect("clicked") {
       on_error
}

def on_error
        md = Gtk::MessageDialog.new(nil, Gtk::Dialog::MODAL | 
             Gtk::Dialog::DESTROY_WITH_PARENT, Gtk::MessageDialog::ERROR, 
             Gtk::MessageDialog::BUTTONS_CLOSE, "No URL specified.")
        md.run
        md.destroy
end

button = Gtk::Button.new("Download")
table.attach(button,4,5,4,5)
button.signal_connect("clicked") {
   $baseDir  = ENV['HOME']
   $musicDir = "#{$baseDir}/Music"
       if entry.position > 0
              entry.delete_text(0,entry.text.length)
       end

       if File.exists?($musicDir) && entryDir.text.empty? && !entry.text.empty?
              `youtube-dl --extract-audio --audio-format mp3 -o "#{$musicDir}" "#{entry.text}/%(title)s.%(ext)s"`
       elsif !File.exists?($musicDir) && entryDir.text.empty?
              Dir::mkdir "#{ENV['HOME']}/Music"
              `youtube-dl --extract-audio --audio-format mp3 -o "#{$musicDir}" "#{entry.text}/%(title)s.%(ext)s"`
       elsif !entryDir.text.empty? && !entry.text.empty?
              if File.exists?("#{$baseDir}/#{entryDir.text}")
                     `youtube-dl --extract-audio --audio-format mp3 -o "#{$baseDir}/#{entryDir.text}/%(title)s.%(ext)s" "#{entry.text}"`
              else
                     FileUtils::mkdir_p "#{$baseDir}/#{entryDir.text}"
                     `youtube-dl --extract-audio --audio-format mp3 -o "#{$baseDir}/#{entryDir.text}/%(title)s.%(ext)s" "#{entry.text}"`
              end
       elsif entry.text.empty?
              puts "Entry is empty."
              on_error
       end
}

table.show
entry.show
button.show
window.show
entryDir.show

Gtk.main

#!/usr/bin/ruby

require 'gtk2'
require 'fileutils'

# Envirenment variables
$baseDir  = ENV['HOME']
$musicDir = "#{$baseDir}/Music"

mainWindow = Gtk::Window.new
mainWindow.signal_connect("destroy") {
       Gtk.main_quit
}

mainWindow.signal_connect("delete_event") {
       false
}

table = Gtk::Table.new(5,6,true)
mainWindow.add(table)

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

errorURL = Gtk::Button.new("Error")
errorURL.signal_connect("clicked") {
       badURL
}

tooltipURL = Gtk::Tooltips.new
tooltipURL.set_tip($entry, "Enter youtube URL here or a file path that that includes a properly formatted playlist.", nil)

tooltipDir = Gtk::Tooltips.new
tooltipDir.set_tip($entryDir, "Enter the directory you wish to save the song to. \nIf it doesnt exist, it will be created", nil)

buttonLogo = Gtk::Button.new
table.attach(buttonLogo,0,5,0,4)

buttonLogoImage = Gtk::Image.new("youtube-logo-transparent_solid.png")
buttonLogo.image = buttonLogoImage

       if !File.exists?("#{$baseDir}/.youtube_dl-gtk")
               Dir::mkdir "#{$baseDir}/.youtube_dl-gtk"
       end

       if !File.exists?($musicDir)
              Dir::mkdir "#{$baseDir}/Music"
       end

def on_error
        md = Gtk::MessageDialog.new(nil, Gtk::Dialog::MODAL | 
             Gtk::Dialog::DESTROY_WITH_PARENT, Gtk::MessageDialog::ERROR, 
             Gtk::MessageDialog::BUTTONS_CLOSE, "No URL specified.")
        md.run
        md.destroy
end

def badURL
        md = Gtk::MessageDialog.new(nil, Gtk::Dialog::MODAL |
             Gtk::Dialog::DESTROY_WITH_PARENT, Gtk::MessageDialog::ERROR,
             Gtk::MessageDialog::BUTTONS_CLOSE, "Improperly formatted URL.")
        md.run
        md.destroy
end

def badDir
        md = Gtk::MessageDialog.new(nil, Gtk::Dialog::MODAL |
             Gtk::Dialog::DESTROY_WITH_PARENT, Gtk::MessageDialog::ERROR,
             Gtk::MessageDialog::BUTTONS_CLOSE, "\"/\" cannot preceed dir.")
        md.run
        md.destroy
end

def delete_text(entry)
       entry.delete_text(0,entry.text.length)
end

# My attempt to get a second window going to place history info in a scrolled window widget.
def childWindow
       $window = Gtk::Window.new
       $window.signal_connect("delete_event") do
             false
       end

       $table2 = Gtk::Table.new(5,6,true)
       $window.add($table2)

       $buttonDelete = Gtk::Button.new("Delete")
       $table2.attach($buttonDelete,4,5,4,5)

       $buttonImg = Gtk::Button.new
       $table2.attach($buttonImg,0,3,0,3)

       $testImg = Gtk::Image.new("youtube-logo-transparent_solid.png")
       $buttonImg.image = $testImg

       $window.show
       $window.move(200,200)
       $testImg.show
       $buttonImg.show
       $buttonDelete.show
end

def downLoadSanityCheck
       if isEntryEmpty?
              on_error
              destroyEntries
       elsif !validFile($entry.text) && urlSanityCheck($entry.text) # Not a file then return true if entry starts with a valid URL
              isDirEmpty? ? download($musicDir,$entry.text) : download($entryDir.text,$entry.text)
              destroyEntries
       elsif validFile($entry.text) 
              File.open($entry.text, "r").each_line do |plist|
                     if urlSanityCheck(plist)
                            $entryDir.text.empty? ? download($musicDir,plist) : download($entryDir.text,plist)
                     else
                            badURL
                            destroyEntries
                     end
              end
              destroyEntries
       end
end

def validFile(file)
       return File.exists?(file)
end

def isDirEmpty?
       return $entryDir.text.empty?
end

def isEntryEmpty?
       return $entry.text.empty?
end

def urlSanityCheck(var)
       if var =~ /^http.*/
              return true
       else
              badURL
              return false
       end
end

def destroyEntries
       delete_text($entry)
       delete_text($entryDir) if !isDirEmpty?
end

def download(dir,entry)

        char = "/"
        charSize = dir.scan(/#{char}/).size

        if charSize >= 2
                `youtube-dl --prefer-avconv --extract-audio --audio-format mp3 -o '#{dir}/%(title)s.%(ext)s' '#{entry}'`
        else
                badDir if dir =~ /^#{char}/
        end

        `youtube-dl --prefer-avconv --extract-audio --audio-format mp3 -o '#{$musicDir}#{dir}/%(title)s.%(ext)s' '#{entry}'` if charSize == 0
end

buttonHistory = Gtk::Button.new("History")
table.attach(buttonHistory,5,6,4,5)
buttonHistory.signal_connect("clicked") do
       childWindow
end

buttonDownload = Gtk::Button.new("Download")
table.attach(buttonDownload,5,6,5,6)
buttonDownload.signal_connect("clicked") do
       downLoadSanityCheck
end

table.show
buttonDownload.show
labelDir.show
labelURL.show
mainWindow.show
buttonLogo.show
buttonHistory.show

$entry.show
$entryDir.show

Gtk.main

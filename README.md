# Opal
 
Opal is the swiss army knife of web apps. It's a powerful Item & Content Management System powered by Ruby on Rails. You can use Opal for blogging, listing items, storing files/images/videos, or for powering any awesome website. 

## Features 

Opal has a a lot of features. Feast your eyes on these:

* System
    * Powered by Ruby on Rails 3.2
	* Store uploaded files locally or in the cloud using Amazon S3, Rackspace Cloud Files, etc. - [(Guide)](http://dev.hulihanapplications.com/projects/opal/wiki/Upload)
    * I18n support for multiple languages & locales. Currently supported languages:
        * en
        * ru
* Interface
    * Easy-to-use TinyMCE content editor with security filtering and image uploader
    * State-of-the-Art Interface powered by HTML5, CSS3, jQuery, Uploadify, and jQuery TOOLS   
    * Mass file & image uploader    
        * Apply special effects to Images: Rotate, Resize, Watermark, Stamp, Monochrome, Sepia, etc.
    * Customizable Themes & Plugins with easy uploader & installer
* Pages & Content
    * CMS-style Page editing with Easy file uploading
    * Integrate Blog
    * Advanced Page features: Group-only access, Redirection, Subpages, etc.
* Items
    * List Any Type of Item: Products, Video Games, Locations, Events, Classifieds, etc.
    * Add extra stuff to your Items like Images, Videos, Reviews, Comments, Files, Discussions, Custom Fields, and more!
    * Infinite-depth category organization & customizable advanced item searching    
* Users
    * Multiple-user login system with secure administration area
    * Login from other websites(facebook, twitter, google, etc.) with OpenID/OAuth Support - [(Guide)](http://dev.hulihanapplications.com/projects/opal/wiki/OAuth)
    * User Activity Logging
    * Gravatar Support    
* [Much More](http://www.hulihanapplications.com/projects/opal)

## Demo

You can try out an online demo of Opal at [http://opal.demos.hulihanapplications.com/](http://opal.demos.hulihanapplications.com/). This is for testing purposes only and is wiped every hour.

## Uses

Since Opal is highly customizable, you can use it for many different things:

* Content Management System (CMS)
* Directory Website
* Blog
* Image/Video Gallery 
* File Download System
* Forum/Discussion Board
* Review/Classifieds Website

![Opal Screenshot](https://github.com/hulihanapplications/Opal/raw/master/public/themes/fracture/screenshot.png "Opal Interface with Default Theme")

# Installation

## Step 1 - Get Opal

Opal is available at the following places:

* [Github](https://github.com/hulihanapplications/Opal)
* [Official Website](http://www.hulihanapplications.com/projects/opal)

If you have git installed on your server, you can install it directly from Github. This is highly recommended and makes updating Opal a breeze.

```sh
git clone git://github.com/hulihanapplications/Opal.git
```

## Step 2 - Install Gems

Install all of Opal's required gems using bundler:

```sh
cd Opal
bundle install --without test development
```

* You may get an error here regarding [rmagick](http://dev.hulihanapplications.com/projects/opal/wiki/RMagick) if you don't have it already installed. Check out this [Wiki Guide](http://dev.hulihanapplications.com/projects/opal/wiki/RMagick) for help.

## Step 3 - Database configurations

Next, edit `config/database.yml` to use your preferred database system. If you don't create this file, one will automatically be generated for you that uses sqlite.

## Step 4 - It's time to rake 

Next, Run these commands (while in the Opal directory) to install Opal's required stuff (database structure, assets, etc.) in production mode: 

```sh
bundle exec rake db:migrate RAILS_ENV=production LOCALE=en
bundle exec rake db:seed RAILS_ENV=production LOCALE=en
bundle exec rake assets:precompile:nondigest

# Install Sample Items, Categories, etc.
bundle exec rake db:sample RAILS_ENV=production LOCALE=en
```

These commands will create the database structure of Opal in production mode. If you leave out *RAILS_ENV=PRODUCTION*, everything will be installed into your development database instead. This will also set up the default admin account, some sample items, and other stuff to help you get started with Opal. You can also specify the *LOCALE* variable to install Opal in a language other than english. 

## Step 5 - Fire 'er up 

You can now start Opal using the 'thin' webserver...

```sh
bundle exec rails s -e production
```

...or any of your other favorite webservers: nginx, apache, mongrel, etc.
 
* To log in to Opal for the first time, the default Admin username and password is: *admin*.

You've now successfully installed Opal. Go grab yourself a sandwich to celebrate. 

## Bonus Step: Updating Opal

If you installed Opal with git, updating is a piece of cake. Go to your Opal directory and run these commands: 

```sh
git pull origin master # pull the latest stable version of Opal
rake db:migrate RAILS_ENV=production
rake assests:precompile RAILS_ENV=production
```

# Extra Stuff 

## Guides & Tutorials

Here's just a few of the [many things](http://dev.hulihanapplications.com/projects/opal/wiki/User%27s_Guide) you can do with Opal:

* [Set up OAuth Authentication to log in through other websites](http://dev.hulihanapplications.com/projects/opal/wiki/OAuth)
* [Use Amazon S3, Rackspace Cloud Files, etc. to store files](http://dev.hulihanapplications.com/projects/opal/wiki/Upload)
* [Create Custom Fields for Items](http://dev.hulihanapplications.com/projects/opal/wiki/Create_Custom_Fields_for_Items)
* [Configure Email & Notifications](http://dev.hulihanapplications.com/projects/opal/wiki/Notifications)
* [Add an ad banner To Opal](http://dev.hulihanapplications.com/projects/opal/wiki/Adding_an_Ad_Banner_To_Opal)
* [How to Watermark Uploaded Images](http://dev.hulihanapplications.com/projects/opal/wiki/Watermarking_Uploaded_Images)

Check out the [Opal Wiki](http://dev.hulihanapplications.com/projects/opal/wiki/User's_Guide for more.)

## Plugins & Themes

You can easily extend and customize Opal with new plugins and themes. *Plugins* extend Opal's core functionality and *Themes* change the appearance of your Opal application. 

Opal has a small but dedicated community of designers and coders that create plugins and themes for public use. You can find them on the official [Opal website](http://hulihanapplications.com/projects/opal#5). Check out the guides below to make your own.
 
# Community & Additional Help

If you need any more help, check out these resources:

* [User's Guide](http://dev.hulihanapplications.com/projects/opal/wiki/User%27s_Guide)
* [Wiki](http://dev.hulihanapplications.com/projects/opal/wiki/)
* [Forum](http://dev.hulihanapplications.com/projects/opal/boards)

# Development & Contribution

If you're interested in developing Opal or contributing a theme, plugin, or translation, check out the following:
* [Submit a bug or feature request](http://dev.hulihanapplications.com/projects/opal/issues)
* [Source Code On Github](https://github.com/hulihanapplications/Opal)
* [Developer's Guide](http://dev.hulihanapplications.com/projects/opal/wiki/Developer%27s_Guide)
    * [Plugin Development Guide](http://dev.hulihanapplications.com/projects/opal/wiki/Plugin_Development)
    * [Theme Development Guide](http://dev.hulihanapplications.com/projects/opal/wiki/Theme_Development)
    * [Locale Development Guide](http://dev.hulihanapplications.com/projects/opal/wiki/Locale_Development)

# License 

Opal is Licensed under the  [Creative Commons Attribution 3.0 United States License](http://creativecommons.org/licenses/by/3.0/us/).

# Kudos

Special Thanks goes to following:

* [Yusuke Kamiyamane](http://p.yusukekamiyamane.com/) for his snazzy fugue icon set.
* The [jQuery Core Team](http://jquery.org/team) for making javascript dance like a puppet.   

#!/usr/bin/env ruby 

#Jacob Hammack
#http://hammackj.com

#A active record migration script for creating tables for parsing the data from .nessus v2 files

#To use this file, type for usage
#./nessus_migrator.rb

require 'rubygems'  
require 'active_record'  
require 'yaml'
require 'optparse' 

$stdout.sync = true

# NessusMigrator 
#
# @version 1.0
# @author Jacob Hammack
class NessusMigrator < ActiveRecord::Migration

	# Creates all of the database tables required by the parser
	#
  def self.up
    create_table :policies do |t|
      t.column :name, :string
      t.column :comments, :string
    end
		
    create_table :server_preferences do |t|
      t.column :policy_id, :integer
      t.column :name, :string
      t.column :value, :string
    end		
		
		create_table :plugins_preferences do |t|
		  t.column :policy_id, :integer
		  t.column :plugin_id, :integer
		  t.column :plugin_name, :string
		  t.column :fullname, :string
		  t.column :preference_name, :string
		  t.column :preference_type, :string		  		  
		  t.column :preference_values, :string
		  t.column :selected_values, :string		  		  		  		  
		end

		create_table :family_selections do |t|
		  t.column :policy_id, :integer
		  t.column :family_name, :string
		  t.column :status, :string
		end		
				
		create_table :reports do |t|
		  t.column :policy_id, :integer
		  t.column :name, :string
		end
		
		create_table :hosts do |t|
		  t.column :report_id, :integer
		  t.column :name, :string
		  t.column :os, :string
		  t.column :mac, :string
		  t.column :start, :datetime
		  t.column :end, :datetime
		  t.column :ip, :string
		  t.column :fqdn, :string
		  t.column :netbios, :string
		  t.column :local_checks_proto, :string
		  t.column :smb_login_used, :string
		  t.column :ssh_auth_meth, :string
		  t.column :ssh_login_used, :string		  		    
		end
	
		create_table :items do |t|
		  t.column :host_id, :integer
		  t.column :plugin_id, :integer
		  t.column :plugin_output, :text
		  t.column :port, :integer
		  t.column :svc_name, :string
		  t.column :protocol, :string
		  t.column :severity, :integer
		  t.column :verified, :boolean
		end	
		
		create_table :plugins do |t|
		  t.column :plugin_name, :string
		  t.column :family_name, :string
		  t.column :description, :text
		  t.column :plugin_version, :string
		  t.column :plugin_publication_date, :datetime
		  t.column :vuln_publication_date, :datetime
      t.column :cvss_vector, :string
      t.column :cvss_base_score, :string
		  t.column :risk_factor, :string
		  t.column :solution, :text
		  t.column :synopsis, :text
	  end
	  
		create_table :individual_plugin_selections do |t|
		  t.column :policy_id, :string
		  t.column :plugin_id, :integer
		  t.column :plugin_name, :string		  
		  t.column :family, :string
		  t.column :status, :string
		end
	  
	  create_table :references do |t|
	    t.column :plugin_id, :integer
		  t.column :reference_name, :string
		  t.column :value, :string
    end
	end
	
	# Deletes all of the database tables created
	#
	def self.down
	  drop_table :policies
	  drop_table :server_preferences
	  drop_table :plugins_preferences
	  drop_table :family_selections
	  drop_table :individual_plugin_selections
	  drop_table :reports
	  drop_table :hosts
	  drop_table :items
	  drop_table :plugins
	  drop_table :references
  end
  
  # Checks to see if the database.yml file exists, if it doesn't exist the program exits.
  #
  def check_for_database_yml
    if File.exists?("database.yml") == false
      puts "[!] You must have a database.yml file with database connection information to continue. Please see the -f option"
      exit
    end
  end
  
  # Parse's the command line options executes them and exits
  #
  def main
    @opt = OptionParser.new { |opt|
      opt.banner =  "NessusDB Database Migrator v1.0\nJacob Hammack\nhttp://www.hammackj.com\n\n"
      opt.banner << "[*] Usage: #{$0} [mode] <options> [targets]"
      opt.separator('')
      opt.separator('Modes:')
    
      opt.on('-c', '--create-tables', 'Create the tables required by NessusDB') { 
        check_for_database_yml      
        require 'nessus_db'  
        NessusMigrator.migrate(:up)
        puts "[*] Tables Created"
        exit
      }

      opt.on('-d', '--delete-tables', 'Delete the tables required by NessusDB') { 
        check_for_database_yml
        require 'nessus_db'
        NessusMigrator.migrate(:down)
        puts "[*] Tables Removed the database will still remain"
        exit
      }
      
      opt.on('-f', '--create-config-file', 'Creates the database.yml required by NessusDB') { 
        if File.exists?("database.yml") == false
          File.open("database.yml", 'w+') { |f| 
            f.write("adapter: \nhost: \nport: \ndatabase: \nusername: \npassword: \ntimeout: \n") 
          }
          
          puts "[*] database.yml created, please fill in the correct information."
          exit
        else
          puts "[!] database.yml already exists, please delete it if you want to recreate it."
        end
        
      }    
               
      opt.on_tail("-h", "--help", "Show this message") { |help|
        puts opt.to_s + "\n"
        exit
      }
    }
      
    if ARGV.length != 0 
      @opt.parse!
    else
      puts @opt.to_s + "\n"
      exit
    end    
  end
  
end

nessus = NessusMigrator.new
nessus.main 

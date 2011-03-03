module ActiveRecord
  module Acts
    #Not sure if putting the modules into this structure actually does some Rails magic or if it's just convention
    module ActsAsUnupdatable

      #This method is called when you use "include" on the ActsAsUnupdatable module
      def self.included(base)
        #This will "extend" the ClassMethods module to add ClassMethods' methods into the module doing the including
        base.extend(ClassMethods)
      end

      module ClassMethods

        # Running ActsAsUnupdatable is equivalent to adding the following code to a class:
        # before_validation :block_update, :on => :update
        #
        # def block_update
        #   raise Exceptions::VersionedObjectUnupdatableException.new("#{self.class} is unupdatable - it can only be created; changes should create a new version")
        # end
        def acts_as_unupdatable
          module_eval do
            before_validation :block_update, :on => :update

            define_method "block_update" do
              #If this object hasn't changed, then don't raise an exception.
			  #This allows saving a parent object that includes this, as long as it doesn't modify it.			 
			  raise Exceptions::VersionedObjectUnupdatableException.new("#{self.class} is unupdatable - it can only be created; changes should create a new version") unless !self.changed?
            end
          end
        end

      end
    end
  end
end

#This is raised if you incorrectly deactivate the last administrator login for a registrant

module Exceptions
  class VersionedObjectUnupdatableException < StandardError
  end
end

#Include this functionality into ActiveRecord::Base so that we can call the methods above from any ActiveRecord object.
ActiveRecord::Base.send(:include, ActiveRecord::Acts::ActsAsUnupdatable)

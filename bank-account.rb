# create a Bank Module
require 'csv'
require 'awesome_print'
require 'chronic'

module Bank
  # initialize Account by pulling in details from a hash
  class Account
    attr_reader :balance, :owner, :id, :created_date, :minimum
    @@bank_accounts = []

    def initialize(account_details_hash)
      @id = account_details_hash[:id]
      @balance = make_into_cents(account_details_hash[:balance]) # balance is in cents
      @created_date = account_details_hash[:created_date]
      @owner = account_details_hash[:owner]
      @minimum = 0
      min_balance(@balance, @minimum)
      # run method complete_info
      # complete_info ######### unhash this once you make the find method!!!!!!!!
      puts "Account is created with #{print_d(@balance)} balance."
    end # end of initialize

    def min_balance(balance,minimum)
      # no putting in negative dollars allowed!!!
      if balance < minimum
        raise ArgumentError.new("Bank account cannot be created with less than #{print_d(@minimum)} balance.")
      end
    end

    def complete_info
      # if there is no ID, create one!
      if @id == nil
        @id = rand(100000..999999).to_s
      end

      # if the account is created without an owner, offers user the opportunity to add an owner
      if @owner == nil
        puts "Would you like to create an owner for this account? Y/N"
        owner_or_not = gets.chomp.downcase
        if owner_or_not == "y" || owner_or_not == "yes"
          puts "Enter first name, press return. Enter last name, press return."
          @owner = Owner.new(first_name: gets.chomp, last_name: gets.chomp)
        else
          puts "Okay, but this account is now ownerless."
        end
      end # end of @owner loop

      # if there is no created date, create one
      if @created_date == nil
        @created_date == Time.now
      end
    end

    def make_into_cents(money)
      if Integer(money) != money
        money = (money * 100).to_i # this stores a float as an int. ie if they \enter 100.00 it multiplies it by 100 and stores that.
      else
        money = money.to_i        # this is just in case there is a float like 2500.0
      end
      return money
    end

    # define a method to withdraw money
    def withdraw(withdrawal) ######## this needs to be in cents, and since there's no gets.chomp I don't think I can do anything to control it????
      withdrawal = make_into_cents(withdrawal)
      # checks to see how the balance and withdrawal are related
      if @balance < withdrawal
        return "Sorry, your balance is #{print_d(@balance)}, and you cannot withdraw an amount larger than your current balance. "
      else
        @balance -= withdrawal
        return "You have withdrawn #{print_d(withdrawal)}. \nYour balance is now #{print_d(@balance)}."
      end

      # returns balance :)
      return balance
    end

    # deposit and dd to blaance
    def deposit(deposit)
      make_into_cents(deposit)
      # checks to see if deposit is less than 0, if so deposits
      if deposit < 0
        return "Depositing negative dollars is not allowed."
      else
        @balance += deposit
        return "You have deposited #{print_d(deposit)}. \nYour balance is now #{print_d(@balance)}."
      end

      # returns balance
      return @balance
    end

    # this makes the cents look nice to print in dollars
    def print_d(dollars)
      dollars = "$" + dollars.to_s.insert(-3, ".")
    end

    # this creates a whole buncha accounts, reading from a CSV
    def self.create_accounts
      CSV.open("./support/accounts.csv", "r").each do |line|
        temporary_account_array = []
        account_details = {}
        account_details[:id] = line[0]
        account_details[:balance] = line[1]
        account_details[:created_date] = line[2]
        temporary_account_array << account_details

        temporary_account_array.each do |item|
          @@bank_accounts << self.new(item)
        end
      end
    end

    # this simply returns all the bank accounts there are
    def self.all
      return @@bank_accounts
    end

    #self.find(id) - returns an instance of Account where the value of the id field in the CSV matches the passed parameter
    def self.find(id)
      # puts "Bank Account ID #{@@bank_accounts[0].id.to_s}"
      @@bank_accounts.each do |account|
          if account.id.to_s == id
            return account
          # else
            # puts "Unable to locate an account with that ID" # originally this was a return, but it quit the loop after the first iteration.
          end
      end
    end # end of self.find method

    # this prints a bank account's info nicely
    def to_s
      return "ID: #{@id}\nBalance: #{print_d(@balance)}\nCreated Date: #{@created_date}"
    end

  end # end of Account class


  class Owner
    attr_reader :owner_id, :first_name, :last_name, :street_address, :city, :state
    @@owners = []

    def initialize(owner_details_hash)
      @owner_id = owner_details_hash[:owner_id]
      @account_id = owner_details_hash[:account_id]
      @first_name = owner_details_hash[:first_name]
      @last_name = owner_details_hash[:last_name]
      @street_address = owner_details_hash[:street_address]
      @city = owner_details_hash[:city]
      @state = owner_details_hash[:state]
    end

    def self.create_owners
      temporary_owners_array = []
      CSV.open("./support/account_owners.csv", "r").each do |line|
        owner_details = {}
        owner_details[:owner_id] = line[0]
        owner_details[:account_id] = line[1]
        temporary_owners_array << owner_details
        # ap temporary_owners_array
      end
        temporary_owners_array.each do |item|
          @@owners << self.new(item)
        end
    end

    def self.all
      return @@owners
    end

    def to_s
        return "Owner ID: #{@owner_id}\nAccount ID: #{@account_id}"
    end

  end # end of Owner class

  class SavingsAccount < Account

    def initialize(account_details_hash)
      super # pulls in initialize method from Account classa
      @minimum = 1000 # this means ten dollars!
      min_balance(@balance, @minimum) # checks to make sure that there is enough money
      return "Account is created with #{print_d(@balance)} balance."
    end

    def withdraw(withdrawal)
      super
      fee = 200 # this means two dollars
      balance = @balance - fee # this removes the fee, we need to print the local variable here instead of the instance variable

      # loop to ensure that the balance is not under the $10 limit, and if not, return the withdrawn amount.
      if balance < 1000
        return "You may not withdraw #{print_d(withdrawal)}. \nThis transaction would make your balance #{print_d(balance)}. \nThe balance must not be below $10.00."
      else
        return "You have withdrawn #{print_d(withdrawal)}.\n There was an additional fee of #{print_d(fee)}\nYour balance is now #{print_d(balance)}."
      end
    end

    def add_interest(rate)
      interest = make_into_cents(@balance * rate/100)
      return "At a rate of #{rate}%, your interest is #{print_d(interest)}."
    end

  end

end # end of Bank

puppy = Bank::SavingsAccount.new(id: 4, balance: 1000000)
puts puppy
# puts puppy.withdraw(4500)
puts puppy.add_interest(0.25)


# ap Bank::Account.all

# puts Bank::Account.find("1217")

# puts Bank::Owner.create_owners

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
      complete_info ######### unhash this once you make the find method!!!!!!!!
      return "Account is created with #{print_d(@balance)} balance."
    end # end of initialize

    # define a method to withdraw money
    def withdraw(withdrawal) ######## this needs to be in cents, and since there's no gets.chomp I don't think I can do anything to control it????
      fee = 0
      status = withdrawal_helper(withdrawal, @minimum, fee)
      return status
    end

    # deposit and add to blaance
    def deposit(deposit)
      make_into_cents(deposit)
      # checks to see if deposit is less than 0, if so deposits
      if deposit < 0
        status = "Depositing negative dollars is not allowed."
      else
        @balance += deposit
        status = "You have deposited #{print_d(deposit)}. \nYour balance is now #{print_d(@balance)}."
      end
      return status
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
          else
            puts "Unable to locate an account with that ID" # originally this was a return, but it quit the loop after the first iteration.
          end
      end
    end # end of self.find method

    # this prints a bank account's info nicely
    def to_s
      return "ID: #{@id}\nBalance: #{print_d(@balance)}\nCreated Date: #{@created_date}"
    end

    #### these methods are private#######
    private
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
        @created_date = Time.now
      end
    end

    def make_into_cents(money)
      if Integer(money) != money
        money = (money * 100).to_i # this stores a float as an int. ie if they \enter 100.25 it multiplies it by 100 and stores that.
      elsif money.to_s.end_with?(".0")
        money = (money * 100).to_i # omfg this method is getting so complicated
      else
        money = money.to_i        # this WAS just in case there is a float like 2500, but now idk if I need it anymore
      end
      return money
    end

    # this makes the cents look nice to print in dollars
    def print_d(dollars)
      if dollars.to_s.length <= 3
        dollars = "$" + sprintf("%03d", dollars).insert(-3, ".") # added this if statement to account for dollar amounts that are less than three characters ($.50 aka 50)
      else
        dollars = "$" + dollars.to_s.insert(-3, ".")
      end
      return dollars
    end

    def min_balance(balance,minimum)
      # no putting in negative dollars allowed!!!
      if balance < minimum
        raise ArgumentError.new("Bank account cannot be created with less than #{print_d(@minimum)} balance.")
      end
    end

    # allows you to incorporate a fee and a min balance
    def withdrawal_helper(withdrawal, minimum, fee)
      withdrawal = make_into_cents(withdrawal) # just being safe with these guys
      fee = make_into_cents(fee)
      minimum = make_into_cents(minimum)
      if (@balance - withdrawal - fee) < minimum
        status = "Sorry, your balance is #{print_d(@balance)}. Including a fee of #{print_d(fee)} and withdrawal of #{print_d(withdrawal)}, you cannot withdraw an amount that will make your balance smaller than the #{print_d(@minimum)} minimum."
      else
        @balance -= (withdrawal + fee)
        status = "You have withdrawn #{print_d(withdrawal)}. \nThere was a fee of #{print_d(fee)}. \nYour balance is now #{print_d(@balance)}."
      end
      return status
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
      puts "Account is created with #{print_d(@balance)} balance."
    end

    def withdraw(withdrawal)
      fee = 200 # this means two dollars
      withdrawal_helper(withdrawal, @minimum, fee)
    end

    def add_interest(rate)
      interest = make_into_cents(@balance * rate/100)
      return "At a rate of #{rate}%, your interest is #{print_d(interest)}."
    end

  end

  class CheckingAccount < Account
    def initialize(account_details_hash)
      super # pulls in initialize method from Account class
      @minimum = 0 # this means ten dollars!
      min_balance(@balance, @minimum) # checks to make sure that there is enough money
      @checks_used = 0
      return "Account is created with #{print_d(@balance)} balance."
    end

    def withdraw(withdrawal)
      fee = 100 # one dolla billz
      withdrawal_helper(withdrawal, @minimum, fee)
    end

    def withdraw_using_check(withdrawal)
      minimum = -1000
      if @checks_used < 3
        fee = 0 # one dolla billz
      else
        fee = 200
      end
      status = withdrawal_helper(withdrawal, minimum, fee) # this is here so that we can do some more stuff before returning.
      @checks_used += 1
      return "#{status}\nYou have used #{@checks_used} check(s) this month."
    end

    private
    def reset_checks
      @checks_used = 0
    end
  end # end of class CheckingAccount

  class MoneyMarket < Account
    def initialize(account_details_hash)
      super
      @minimum = 1000000 #ten thousand buckaroos
      @max_transactions = 6
      @transactions_blocked = false
      @total_transactions = 0
      min_balance(@balance, @minimum) # checks to make sure that there is enough money
      status = "Account is created with #{print_d(@balance)} balance.\n**********"
      puts status
    end

    def withdraw(withdrawal)
      withdrawal = make_into_cents(withdrawal)
      if check_if_blocked?
        status = "Withdrawal not allowed. \nThere have been #{@total_transactions} transaction this month, and only #{@max_transactions} are allowed per month. \nTransactions are blocked for the remainder of the month."
      elsif check_if_overdrawn?
        status = "Withdrawal not allowed. \nTransactions are blocked until balance is #{print_d(@minimum)} or greater. \nPlease deposit funds."
      else
        status = mm_withdrawal(withdrawal)
        @total_transactions += 1
      end
    return status
    end

    def deposit(deposit)
      deposit = make_into_cents(deposit)
      if check_if_blocked?
        status = "Deposit not allowed. \nThere have been #{@total_transactions} transaction this month, and only #{@max_transactions} are allowed per month. \nTransactions are blocked for the remainder of the month."
      elsif check_if_overdrawn?
        status = deposit_while_overdrawn(deposit)
      else
        @total_transactions += 1
        status = super
        #woo hoo, just call parent deposit method
      end
      return status
    end

    ###private methods###
    def block
      @transactions_blocked = true
    end

    def unblock
      @transactions_blocked = false
    end

    def reset_transactions
      @total_transactions = 0
    end

    def check_if_blocked? # checks if transactions are at max. if they are, returns true. if not, false.
      if @total_transactions >= 6
        block
        return true
      end
    end

    def check_if_overdrawn?
      if @transactions_blocked
        return true
      end
    end

    def mm_withdrawal(withdrawal) ### add logic for depositing til less than zero ZERO!!!
      withdrawal = make_into_cents(withdrawal)
      fee = 100
      if (@balance - withdrawal) >= @minimum
        fee = 0
        withdrawal_helper(withdrawal, @minimum, fee)
      elsif (@balance - withdrawal - fee) <= 0              # this won't allow you to withdraw at all if
        return "Cannot withdraw #{print_d(withdrawal)}\nBalance is #{print_d(@balance)}. Balance must not be less than $0.00."
      else
        block
        @balance = @balance - withdrawal - fee
        return "You have withdrawn #{print_d(withdrawal)}.\nYour balance is now #{print_d(@balance)}, which is below the minimum of #{print_d(@minimum)}.\nYour account will be locked until you deposit #{print_d(@minimum - @balance)} or more."
      end
    end

    def deposit_while_overdrawn(deposit)
      deposit = make_into_cents(deposit)
      if deposit + @balance >= @minimum
        unblock
        @balance += deposit
        return "Your deposit of #{print_d(deposit)} has been accepted and your account has been unblocked. \nBalance is #{print_d(@balance)}."
        # do not increase transactions!
      else
        return "Your deposit must increase your balance to #{print_d(@minimum)} Please deposit #{print_d(@minimum - @balance)} or more."
      end
    end

  end # end of MM

end # end of Bank


mm = Bank::MoneyMarket.new(id:5093830, balance:5000000)
puts mm
puts mm.created_date
# puts "*****"
# puts mm.withdraw(500000) # withdraw 5k, should be 45k 1
# puts "****"
# puts mm.withdraw(1000000) # withdraw 10k, should be 35k 2
# puts "***"
# puts mm.withdraw(1000000) # withdraw 10k, should be 25k 3
# puts "****"
# puts mm.deposit(500000)  #deposit 5k, should be 30k 4
# puts "****"
# puts mm.withdraw(500000)  #withdraw 5k, should be 25k 5
# puts "****"
# puts mm.withdraw(500000)#withdraw 5k, should be 20k 6
# puts "****"
# puts mm.withdraw(5000) # SHOULD NOT BE ALLOWED
# puts "****"
# # puts mm.withdraw()
# puts "****"
# # puts mm.deposit()
# puts "****"
# puts mm.deposit(50000) #should not be allowed

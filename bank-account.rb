# create a Bank Module

module Bank
  # initialize Account by pulling in details from a hash
  class Account
    attr_accessor :balance
    attr_reader :owner, :id

    def initialize(account_details_hash)
      @id = account_details_hash[:id]
      @balance = account_details_hash[:balance].to_f
      @owner = account_details_hash[:owner]

      # no putting in negative dollars allowed
      if @balance < 0
        raise ArgumentError.new("Bank account cannot be created with negative balance.")
      else
        puts "Account is created with #{print_d(@balance)} balance."
      end

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

    end # end of initialize

    # define a method to withdraw money
    def withdraw(withdrawal)

      # checks to see how the balance and withdrawal are related
      if @balance < withdrawal
        puts "Sorry, your balance is #{print_d(@balance)}, and you cannot withdraw an amount larger than your current balance. "
      else
        @balance -= withdrawal
        puts "You have withdrawn #{print_d(withdrawal)}. \nYour balance is now #{print_d(@balance)}."
      end

      # returns balance :)
      return @balance
    end

    # deposit and dd to blaance
    def deposit(deposit)
      # checks to see if deposit is less than 0, if so deposits
      if deposit < 0
        puts "Depositing negative dollars is not allowed."
      else
        @balance += deposit
        puts "You have deposited #{print_d(deposit)}. \nYour balance is now #{print_d(@balance)}."
      end

      # returns balance
      return @balance
    end

    # this method reverts the storage in cents back to regular money syntax for people to read
    def print_d(dollars)
      dollars = "$" + sprintf("%.2f",dollars)
    end
  end # end of Account class


  class Owner
    attr_reader :first_name, :last_name

    def initialize(owner_details_hash)
      @first_name = owner_details_hash[:first_name]
      @last_name = owner_details_hash[:last_name]
    end

  end # end of Owner class

end # end of Bank


account_1 = Bank::Account.new(id: rand(100000..999999).to_s, balance: 500, owner: {first_name: "Joe", last_name: "Schmoe"})
account_2 = Bank::Account.new(balance: 600) # trying it out with no ID or owner
account_1.withdraw(300.4)
account_1.deposit(1000)
yay = account_2.id
puts yay



# a bunch of shit I wrote to try to store dollars as cents,
# but turns out that was not necessary for this project,


    # start here, and call this method elsewhere
    # def check_balance
    #   return @balance.to_f
    # end

    # # this method stores $10.00 => 1000
    # def convert_dollars_to_fixnum(dollars)
    #   dollars =  sprintf("%.2f",dollars.to_f)
    #   dollars = dollars.delete(".").to_i
    # end

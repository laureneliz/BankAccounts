# accounts_array =  []
#
# CSV.open("./support/accounts.csv", "r").each do |line|
#   account_details = {}
#   account_details[:id] = line[0]
#   account_details[:balance] = line[1]
#   account_details[:created_date] = line[2]
#   accounts_array << account_details
# end
#
#   accounts_array.each do |item|
#     Bank::Account.new(item)
#   end



# account_2 = Bank::Account.new(balance: 600) # trying it out with no ID or owner
# account_1.withdraw(300.4)
# account_1.deposit(1000)
# yay = account_2.id
# puts yay



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

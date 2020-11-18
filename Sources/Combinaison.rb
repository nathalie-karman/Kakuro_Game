require 'gtk3'
include Gtk

# classe Combinaison
#
# Les objets de cette classes sont caractérisés par : la valeur de la case, 
# le nombre de cases pour effectuer la somme, liste de combinaisons
#
# Les objets de cette classe sont capables de :
# - D'initialiser la valeur de la case
# - D'initialiser le nombre de cases pour la somme
# - De calculer les combinaisons possibles pour un nombre de cases donné et une valeur donnée

class Combinaison

	#@val => valeur de la case
	#@nbCases => nombre de cases pour effectuer la somme
	#@list => liste des combinaisons

	# Méthode d'instance init()
	#
	# Initialise une liste de combinaison pour une valeur et un nombre de cases donnés
	def initialize(val,nbCases)
		@val = val
		@nbCases = nbCases
		@list = Array.new
	end

	# redéfinition du initialize pour une meilleure compréhension au niveau du code
	def Combinaison.creer(val,nbCases)
		new(val,nbCases)
	end

	# Méthode d'instance setNC
	#
	# Permet de définir le nombre de cases pour effectuer la somme
	# Prend le nombre de cases en paramètre
	def setNbCases(nC)
		@nbCases = nC
	end

	# Méthode d'instance multi
	#
	# Permet d'initialiser un tableau multidimensionnel (Le tableau va nous servir de liste de combinaisons)
	# Prend la position x, la position y et la valeur à ajouter dans la liste
  	def multi(x,y,value)
		@list[x] ||= []
		@list[x][y] = value
		#p value
	end

	# Méthode d'instance calcul
	#
	# Permet de calculer toutes les combinaisons possibles pour une valeur et un nombre de cases donnés
	# Ne prend pas de paramètre
	def calcul(tabVal)
			pos = 0
			# Boucle Case pour chaque cas de nombre de cases possible

			case @nbCases
			when 2
				for i in 1..9 do
					for j in 1..9 do
						if i + j == @val && i!=j
							multi(pos,0,i)
							multi(pos,1,j)
							pos += 1
						end
					end
				end
			
			when 3
				for i in 1..9 do
					for j in 1..9 do
						for k in 1..9 do
							if i + j + k == @val && i!=j && i!=k && j!=k
								multi(pos,0,i)
								multi(pos,1,j)
								multi(pos,2,k)
								pos += 1
							end
						end
					end
				end
			
			when 4
				for i in 1..9 do
					for j in 1..9 do
						for k in 1..9 do
							for l in 1..9 do
								if i + j + k + l == @val && i!=j && i!=k && j!=k && l != i && l != j && l != k
									multi(pos,0,i)
									multi(pos,1,j)
									multi(pos,2,k)
									multi(pos,3,l)
									pos += 1
								end
							end
						end
					end
				end

			when 5
				for i in 1..9 do
					for j in 1..9 do
						for k in 1..9 do
							for l in 1..9 do
								for m in 1..9 do
									if i + j + k + l + m == @val && i!=j && i!=k && j!=k && l != i && l != j && l != k && m != i && m != j && m != k && m != l
										multi(pos,0,i)
										multi(pos,1,j)
										multi(pos,2,k)
										multi(pos,3,l)
										multi(pos,4,m)
										pos += 1
									end
								end
							end
						end
					end
				end

			when 6
				for i in 1..9 do
					for j in 1..9 do
						for k in 1..9 do
							for l in 1..9 do
								for m in 1..9 do
									for n in 1..9 do
										if i + j + k + l + m + n == @val && i!=j && i!=k && j!=k && l != i && l != j && l != k && m != i && m != j && m != k && m != l && n != i && n != j && n != k && n != l && n != m
											multi(pos,0,i)
											multi(pos,1,j)
											multi(pos,2,k)
											multi(pos,3,l)
											multi(pos,4,m)
											multi(pos,5,n)
											pos += 1
										end
									end
								end
							end
						end
					end
				end

			when 7
				for i in 1..9 do
					for j in 1..9 do
						for k in 1..9 do
							for l in 1..9 do
								for m in 1..9 do
									for n in 1..9 do
										for o in 1..9 do
											if i + j + k + l + m + n + o == @val && i!=j && i!=k && j!=k && l != i && l != j && l != k && m != i && m != j && m != k && m != l && n != i && n != j && n != k && n != l && n != m && o != i && o != j && o != k && o != l && o != m && o != n   
												multi(pos,0,i)
												multi(pos,1,j)
												multi(pos,2,k)
												multi(pos,3,l)
												multi(pos,4,m)
												multi(pos,5,n)
												multi(pos,6,o)
												pos += 1
											end
										end
									end
								end
							end
						end
					end
				end
			else
				#puts "Error"
			end

			#------------------
			# enlever les propositions en fonction de ce que l'utilisateur a rempli ou non 
			#------------------

			listTampon = Array.new{Array.new()}

			if tabVal != []
				@list.each{ |e|
					if e.join.include?(tabVal.join)
						listTampon<<e
					end
				}
				@list = listTampon
			end
		
			#Effacer les doublons dans la liste
			@list.each{ |x|
				x.sort!
			}
				
			#p @list
			if(@list == [])
				return @list<<[0]
			else
				return @list.uniq!
			end
 	end
end
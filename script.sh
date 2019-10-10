#!/bin/sh
response="default"
echo "Bonjour, bienvenue dans l'assitance d'installation de Virtualbox et vagrant. "
while [ $response != "stop" ]
do
  read -p "Voulez lancer une installation de Virtualbox et Vagrant, oui/non ?" response

    case $response in
      "oui")
        echo "j'initialise l'installation..."
        # Je verifie si virutalbox et vagrant sont installés, j'installe si ce n'est pas le cas
        virtualbox="$(which virtualbox)"
        vagrant="$(which vagrant)"
        if [[ $virtualbox == "" ]]
        then
          echo "Virtualbox n'est pas installer, lancement de l'installation"
          sudo apt-get install virtualbox
        else
          echo "Virtualbox est déjà installé"
        fi
        if [[ $vagrant == "" ]]
        then
          echo "Vagrant n'est pas installer, lancement de l'installation"
          sudo apt-get install vagrant
        else
          echo "vagrant est déjà installé"
        fi
        echo "Je lance la création du vagrantfile..."
        vagrant init
        rm -rf Vagrantfile
        touch Vagrantfile
        echo "Vagrant.configure(\"2\") do |config|" >> Vagrantfile
        read -p "Voulez-vous donner un nom au dossier synchronisée local et vagrant, oui/non? " response

        case $response in
          "oui")
            read -p "Quel nom voulez-vous donner au dossier local ? : " syncFolderName
            read -p "Quel nom voulez-vous donner au dossier vagrant ? : " syncFolderVagrantName
            mkdir $syncFolderName ;;
          "non")
            syncFolderName="data"
            syncFolderVagrantName="data_vagrant"
            mkdir $syncFolderName
            echo "le dossier aura par defaut le nom de 'data'"
          ;;
          *)
            echo "je n'ai pas compris, les paramétres seront par défaut."
            syncFolderName="data"
            syncFolderVagrantName="data_vagrant"
            mkdir $syncFolderName
        esac

        echo "le dossier $syncFolderName et le dossier $syncFolderVagrantName à été créer avec succés."
        read -p "Quel type  ubuntu/xenial64 , ubuntu/trusty64 ,envimation/ubuntu-xenial-docker ? : " choiceType

        #Vérification du choix de box
        while [[ $choiceType != "ubuntu/xenial64" && $choiceType != "ubuntu/trusty64" && $choiceType != "envimation/ubuntu-xenial-docker" ]]
        do
          echo "Je n'ai pas compris, réessayer..."
          read -p "Quel type  ubuntu/xenial64 , ubuntu/trusty64 ,envimation/ubuntu-xenial-docker ? : " choiceType
        done
        echo "config.vm.box = \"$choiceType\"" >> Vagrantfile
        read -p "Voulez-vous changer l'adresse IP par défaut, oui/non ? " responseIp

        case $responseIp in
          "oui")
            read -p "Quel chiffre voulez vous donner ? " numberForIp
            isNumber=ok
            regx='^[0-9]+$'
            if ! [[ $numberForIp =~ $regx ]]
            then
              isNumber=notOk
            fi
            #Vérification du chiffre entrer pour l'adresse IP
            while [[ $isNumber == "notOk" || $numberForIp -gt 254 ]]
            do
              read -p "Choisissez un chiffre entier avec la valeur maximal 254 : " numberForIp
              if ! [[ $numberForIp =~ $regx ]]
              then
                isNumber=notOk
              else
                isNumber=ok
              fi
            done
            echo "l'adresse choisie est : $numberForIp"
            ;;
          "non")
            echo "Trés bien continuons avec les valeurs par défaut..."
            numberForIp=10
          ;;
          *)
            echo "Je n'ai pas compris je continue avec les valeurs par défaut..."
            numberForIp=10
        esac

        echo "config.vm.network \"private_network\", ip: \"192.168.33.$numberForIp\"" >> Vagrantfile
        echo "config.vm.synced_folder \"./$syncFolderName\", \"/var/www/html/$syncFolderVagrantName\"" >> Vagrantfile
        echo "end" >> Vagrantfile
        vagrant up
        echo "le vagrantfile est mis en place, la VM est lancée"

        read -p "Voulez allumer ou éteindre une Vm , oui/non ?" responseVagrantManager

        case $responseVagrantManager in
          "oui")
            echo "Voici les environements vagrant disponible : "
            vagrant global-status
          ;;
          "non")
            echo "on passe à la suite"
            ;;
          *)
            echo "je n'ai pas compris"
        esac

        # vagrant ssh -c "cd /var/www/$syncFolderVagrantName ; sudo apt-get update ; sudo apt-get -y install apache2 mysql-server php7.0 ; sudo service apache2 restart"
        ;;
      "non")
        echo "Trés, a une prochaine fois peut être. Au revoir!"
        response="stop"
        ;;
      "stop")
          response="stop"
        ;;
        *)
          echo "Désoler je n'ai pas compris votre réponse, réessayer..."
    esac
done

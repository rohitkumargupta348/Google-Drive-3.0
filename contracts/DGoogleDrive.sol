// SPDX-License-Identifier: MIT
pragma solidity >0.5.0 <=0.9.0;

contract DGoogleDrive{
    struct access{
        address user;//address of user to whom we want to give access
        bool flag;//tells whether we have to give access or not
    }

    mapping(address=>string[]) value;//stores address and the array stores all images of that address
    mapping(address=>access[]) accessList;//contains all address to which access is given
    mapping(address=>mapping(address=>bool)) ownership;//this helps the owner to tell which address should be given the access[ownership[address][address]=bool]
    mapping(address=>mapping(address=>bool)) previousData;//since we are only dependent on blockchain and have no server we have to keep track of previous data so we are using this
    
    function addImage(address _user,string memory _url) external{
        value[_user].push(_url);
    }

    function allowAccess(address _user) external{
        ownership[msg.sender][_user]=true;
        //suppose we take any address and allow it to acces our image but later we disallow it to use, when we disallow it then we change only attributes and that address is not deleted
        // but then we again allow it to access our image then to avoid address repetation we keep a track whether the address we have was previously allowed or not
        if(previousData[msg.sender][_user]){
            for(uint i=0;i<accessList[msg.sender].length;i++){
                if(accessList[msg.sender][i].user==_user){
                    accessList[msg.sender][i].flag=true;
                }
                else{
                    accessList[msg.sender].push(access(_user,true));
                    previousData[msg.sender][_user]=true;
                }
            }
        }    
    }

    function disallowAccess(address user) public {
        ownership[msg.sender][user]=false;
        //we have to remove this address from our access list
        for(uint i=0;i<accessList[msg.sender].length;i++){
            if(accessList[msg.sender][i].user == user){
                accessList[msg.sender][i].flag=false;//here we make changes in attributes of any address and do not delete the address
            }
        }
    }

    function display(address _user) view external returns(string[] memory){
        require(_user==msg.sender || ownership[_user][msg.sender],"You are not allowed to access owner image");
        return value[_user];
    }

    function shareAccess() view public returns(access[] memory){
        return accessList[msg.sender];
    }

}
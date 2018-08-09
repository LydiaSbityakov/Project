declare

  v_first_name    member.first_name%TYPE:='&name';
  v_last_name     member.last_name%TYPE:='&lname';
  v_street        member.street%TYPE:='&street';
  v_city          member.city%TYPE:='&city';
  v_phone         member.phone%TYPE:='&phone';
  v_member_id     member.Member_ID%TYPE;
   v_sqlcode VARCHAR2(30);
  v_sqlerrm VARCHAR2(100); 
  begin
  
     select member.member_id 
     into v_member_id 
     from member 
     where member.first_name= v_first_name  
     and member.last_name = v_last_name
     and PHONE = v_phone;
    
     if sql%found then
        
         dbms_output.put_line('Your member id is:  ' || v_member_id);
      
      end if;
    
  exception
  
  when no_data_found then
  
      add_member(v_first_name, v_last_name, v_street,
      v_city, v_phone, v_member_id );
      
      dbms_output.put_line('Your new member id is:  ' || v_member_id);
  
  when others then
      v_sqlcode := SQLCODE;
      v_sqlerrm := SQLERRM;
      dbms_output.put_line('ERROR CODE ' || v_sqlcode || ' ERROR MESSAGE ' || v_sqlerrm);
  
  end;
  /
  
  
  

declare

  v_copy_id title_copy.copy_id%TYPE:='&copy_id';
  v_title_name TITLE_COPY.TITLE_NAME%TYPE;
  v_member_id MEMBER.member_id%TYPE;
  v_member_fname member.first_name%TYPE;
  v_member_lname member.last_name%TYPE;
  v_member_phone member.phone%TYPE;
  
  v_sqlcode VARCHAR2(30) := SQLCODE;
  v_sqlerrm VARCHAR2(100) := SQLERRM;

  
begin
  
  dbms_output.put_line('Checking in video.  Copy id:  ' || v_copy_id);
  
  CHECKIN(v_copy_id, v_title_name, v_member_fname, v_member_lname, v_member_phone);

  if v_member_lname is not null then
    dbms_output.put_line('There is a reservation for this title:  ' || v_title_name);
    dbms_output.put_line('Contact member:  ' || v_member_fname || ' ' || v_member_lname);
    dbms_output.put_line('Phone:  ' || v_member_phone);
  else 
    dbms_output.put_line('There are no current reservations for this title.');
 
  end if;  
  
  exception  
        
    when others then
      v_sqlcode := SQLCODE;
      v_sqlerrm := SQLERRM;
      dbms_output.put_line('ERROR CODE ' || v_sqlcode || ' ERROR MESSAGE ' || v_sqlerrm);
      
END;
/
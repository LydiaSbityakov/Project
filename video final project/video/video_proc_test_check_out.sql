
declare
  v_title_name TITLE_COPY.TITLE_NAME%TYPE:='&movie';
  v_member_id MEMBER.member_id%TYPE := '&id';
  v_copy_id title_copy.copy_id%TYPE;
  v_sqlcode VARCHAR2(30) := SQLCODE;
  v_sqlerrm VARCHAR2(100) := SQLERRM;

  
begin
  
    
  dbms_output.put_line('Finding copy id...');
  
  video.find_available_copy_id(v_title_name, v_copy_id);

  if v_copy_id is not null then
    video.checkout(v_member_id, v_copy_id);
    dbms_output.put_line(v_title_name || '  copy id:  ' || v_copy_id || ', checked out to Member No. ' || v_member_id); 
    
  else 
    dbms_output.put_line('There are no copies of ' || v_title_name || ' available.  Ask an employee about making a reservation.');
  end if;
  
  exception  
    
    when no_data_found then
      dbms_output.put_line('Title or member not found.');
    
    --when parent_key_not_found then
    --dbms_output.put_line('The membership id you entered is not valid.  Please talk to an employee.');
    
    when others then
      v_sqlcode := SQLCODE;
      v_sqlerrm := SQLERRM;
      dbms_output.put_line('ERROR CODE ' || v_sqlcode || ' ERROR MESSAGE ' || v_sqlerrm);
        
END;
/
  
  
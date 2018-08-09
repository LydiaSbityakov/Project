create or replace package body video
is 

-- Package contains
-- PROCEDURES
-- find_available_copy_id
-- get_reservation_info
-- add_member
-- checkout
-- checkin



procedure find_available_copy_id(
  p_title_name  IN  title_copy.title_name%TYPE, 
  p_copy_id     OUT title_copy.copy_id%type)
  
  IS
   
  v_sqlcode VARCHAR2(30);
  v_sqlerrm VARCHAR2(100);
  
  CURSOR copy_id_cur IS
    select COPY_ID ,TITLE_ID ,STATUS ,TITLE_NAME  
    from title_copy 
    where title_copy.title_name = upper(p_title_name)
    and title_copy.status = 'IN STORE';
  
  BEGIN
    FOR v_title_copy_rec IN copy_id_cur
      LOOP
          p_copy_id := v_title_copy_rec.copy_id; 
          exit when sql%found;
      END LOOP;
      
  EXCEPTION
    when NO_DATA_FOUND then
      dbms_output.put_line('Title is not available.  The member may request a reservation for this title.');
    
    when others then
      v_sqlcode := SQLCODE;
      v_sqlerrm := SQLERRM;
      dbms_output.put_line('ERROR CODE ' || v_sqlcode || ' ERROR MESSAGE ' || v_sqlerrm);
      
END find_available_copy_id;

procedure get_reservation_info
  ( p_copy_id IN title_copy.copy_id%TYPE,
    v_title_name OUT title_copy.title_name%TYPE,
    v_member_fname OUT member.first_name%TYPE,
    v_member_lname OUT member.last_name%TYPE,
    v_member_phone OUT member.phone%TYPE
  )
  
  IS
  
  v_copy_id rental.copy_id%TYPE := p_copy_id;
  v_title_id VARCHAR2(30);
  v_status VARCHAR2(30) := 'IN STORE';
  v_member_id MEMBER.MEMBER_ID%TYPE;
  
  CURSOR reservation_cur is 
    select reservation.member_id 
      from reservation  
      where reservation.title_id = v_title_id
      order by RESERVE_DATE asc;
  
  v_sqlcode VARCHAR2(30) := SQLCODE;
  v_sqlerrm VARCHAR2(100) := SQLERRM;
  
  
  BEGIN
  
    -- get title id and check if there are any reservations for this title
    -- add logic here - continue with other queries only if there is 
    -- a record found here
    select title_copy.title_id, title_copy.title_name into v_title_id, v_title_name
      from title_copy
      where v_copy_id = title_copy.copy_id;
    
    if sql%found then    
      -- use the title id to see if there are any reservations for this title  
      -- get the member number of the earliest reservation if there is one
      -- need to user a cursor here:
      for v_reservation_rec in reservation_cur LOOP
          v_member_id := v_reservation_rec.member_id;
          exit when reservation_cur%rowcount>1;   
      END LOOP;
        
      -- finally, query the member table to obtain the member name and phone number
      select member.first_name, member.last_name, member.phone 
        into v_member_fname, v_member_lname, v_member_phone 
        from member
        where member.member_id = v_member_id;
        
      -- delete reservation record
      delete from reservation
      where reservation.title_id = v_title_id
      and reservation.member_id = v_member_id;
      dbms_output.put_line('Deleting reservation for Title ID:   ' || v_title_id || ' Member:  ' || v_member_id);
      
    end if;  
  
  exception  
    when others then
      v_sqlcode := SQLCODE;
      v_sqlerrm := SQLERRM;
      dbms_output.put_line('ERROR CODE ' || v_sqlcode || ' ERROR MESSAGE ' || v_sqlerrm);
        
END get_reservation_info;

procedure add_member(
  v_first_name    member.first_name%TYPE,
  v_last_name     member.last_name%TYPE,
  v_street        member.street%TYPE,
  v_city          member.city%TYPE,
  v_phone         member.phone%TYPE,
  v_member_id     OUT   member.Member_ID%TYPE
)
is
  v_sqlcode VARCHAR2(30);
  v_sqlerrm VARCHAR2(100);
   
-- if member already is in the system
-- return "Already a member:  member_id

begin 
  
  select member_id into v_member_id
  from member
  where 
    FIRST_NAME = v_first_name and
    LAST_NAME = v_last_name and
    STREET = v_street and
    CITY = v_city and
    PHONE = v_phone;
  
    if sql%rowcount=1 then
      dbms_output.put_line('Already a member.  Member ID: ' || v_member_id);    
    END IF;
  
  
exception 
  when TOO_MANY_ROWS then 
    dbms_output.put_line('Multiple records return for this customer information.');
 
 when NO_DATA_FOUND then
     -- create a new member record
      v_member_id := S_MEMBER_ID.NEXTVAL;
      
      insert into MEMBER values(
        v_member_id,
        v_first_name,
        v_last_name,
        v_street,
        v_city,
        v_phone,
        sysdate,
        0
      );
    
    commit;
    dbms_output.put_line('New member.  Member ID: ' || v_member_id);
  

  when others then
  v_sqlcode := SQLCODE;
  v_sqlerrm := SQLERRM;
  dbms_output.put_line('ERROR CODE ' || v_sqlcode || ' ERROR MESSAGE ' || v_sqlerrm);
    
end add_member;

procedure checkout(
  p_member_id IN MEMBER.MEMBER_ID%TYPE,
  p_copy_id IN title_copy.copy_id%TYPE
)

IS

v_checkout_date rental.checkout_date%TYPE := sysdate;
v_copy_id rental.copy_id%TYPE := p_copy_id;
v_member_id rental.member_id%TYPE := p_member_id;
v_exp_return_date rental.exp_return_date%TYPE := sysdate + 3;
v_status VARCHAR2(30) := 'OUT STORE';
v_sqlcode VARCHAR2(30) := SQLCODE;
v_sqlerrm VARCHAR2(100) := SQLERRM;


BEGIN

insert into rental values (
v_checkout_date, 
v_copy_id,
v_member_id,
null,
v_exp_return_date
);

-- THIS UPDATE STATEMENT IS REPLACED BY TRIGGER
-- up date status
-- this update statement can be replace with a trigger
-- update title_copy
-- set status = v_status
-- where copy_id = v_copy_id;


--where 
dbms_output.put_line('Checkout date: ' || v_checkout_date || '  Copy ID: ' || p_copy_id || '  Member ID:  ' || v_member_id ||  '  Return date:  ' || v_exp_return_date);
  
exception  
when others then
  v_sqlcode := SQLCODE;
  v_sqlerrm := SQLERRM;
  dbms_output.put_line('ERROR CODE ' || v_sqlcode || ' ERROR MESSAGE ' || v_sqlerrm);
    
END checkout;

procedure checkin(
  p_copy_id IN title_copy.copy_id%TYPE,
  v_title_name OUT title_copy.title_name%TYPE,
  v_member_fname OUT member.first_name%TYPE,
  v_member_lname OUT member.last_name%TYPE,
  v_member_phone OUT member.phone%TYPE
)

IS

v_copy_id rental.copy_id%TYPE := p_copy_id;
v_title_id VARCHAR2(30);
v_status VARCHAR2(30) := 'IN STORE';
v_member_id MEMBER.MEMBER_ID%TYPE;
v_sqlcode VARCHAR2(30) := SQLCODE;
v_sqlerrm VARCHAR2(100) := SQLERRM;


BEGIN
-- update rental record for returning video
-- set the checkin date equal to sysdate
update rental 
  set rental.checkin_date = sysdate 
  where rental.copy_id = v_copy_id;

-- THIS UPDATE REPLACED WITH TRIGGER
-- up date status of returning video record to 'IN STORE'

-- get title id and check if there are any reservations for this title
video.get_reservation_info(v_copy_id, v_title_name, v_member_fname, 
v_member_lname, v_member_phone);

exception  

when others then
  v_sqlcode := SQLCODE;
  v_sqlerrm := SQLERRM;
  dbms_output.put_line('ERROR CODE ' || v_sqlcode || ' ERROR MESSAGE ' || v_sqlerrm);
    
END checkin;

end video;
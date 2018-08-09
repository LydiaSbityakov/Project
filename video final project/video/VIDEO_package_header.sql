create or replace package video

IS



procedure find_available_copy_id(
  p_title_name  IN  title_copy.title_name%TYPE, 
  p_copy_id     OUT title_copy.copy_id%type);

procedure get_reservation_info
  ( p_copy_id IN title_copy.copy_id%TYPE,
    v_title_name OUT title_copy.title_name%TYPE,
    v_member_fname OUT member.first_name%TYPE,
    v_member_lname OUT member.last_name%TYPE,
    v_member_phone OUT member.phone%TYPE);

 procedure checkin
  (p_copy_id IN title_copy.copy_id%TYPE,
  v_title_name OUT title_copy.title_name%TYPE,
  v_member_fname OUT member.first_name%TYPE,
  v_member_lname OUT member.last_name%TYPE,
  v_member_phone OUT member.phone%TYPE);
  
  procedure add_member
  ( v_first_name    member.first_name%TYPE,
  v_last_name     member.last_name%TYPE,
  v_street        member.street%TYPE,
  v_city          member.city%TYPE,
  v_phone         member.phone%TYPE,
  v_member_id     OUT   member.Member_ID%TYPE);
  
  procedure checkout
  ( p_member_id IN MEMBER.MEMBER_ID%TYPE,
  p_copy_id IN title_copy.copy_id%TYPE);
  
  
end video;